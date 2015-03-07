require "helper"

set :environment, :test
OmniAuth.config.test_mode = true

describe "The Campaign Monitor Subscribe Form app" do
  let(:app) { Sinatra::Application }
  let(:user_id) { "7654321" }
  let(:fb_token) { "xxxx" }
  let(:cm_api_key) { "testapikey" }

  describe "GET /auth/facebook/callback?code=xyz" do
    let(:auth_hash) {
      {
        "provider" => "facebook",
        "uid" => user_id,
        "info" => {},
        "credentials" => {
          "token" => fb_token,
          "expires_at" => "1321747205",
          "expires" => "true"
        },
        "extra" => {}
      }
    }

    before do
      OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(auth_hash)
    end

    it "stores the correct session values and redirects" do
      get "/auth/facebook/callback"

      expect(last_request.env["rack.session"]["fb_auth"]["uid"]).to eq(user_id)
      expect(last_request.env["rack.session"]["fb_token"]).to eq (fb_token)
      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq("http://example.org/")
    end
  end

  describe "GET /" do
    context "when there's no session for the user" do
      it "redirects to request authorisation" do
        get "/"

        expect(last_request.env["rack.session"]["fb_auth"]).to be_nil
        expect(last_request.env["rack.session"]["fb_token"]).to be_nil
        expect(last_response.status).to eq(302)
        expect(last_response.location).to eq("http://example.org/auth/facebook")
      end
    end

    context "when there's a session for the user but it doesn't match the current fb user" do
      it "clears the session and redirects to request authorisation" do
        get "/",
          { "facebook" => { "user_id" => user_id } },
          { "rack.session" => { "fb_auth" => { "uid" => "1234567" } } }

        expect(last_request.env["rack.session"]["fb_auth"]).to be_nil
        expect(last_request.env["rack.session"]["fb_token"]).to be_nil
        expect(last_response.status).to eq(302)
        expect(last_response.location).to eq("http://example.org/auth/facebook")
      end
    end

    context "when the user is successfully authenticated but hasn't authed with Campaign Monitor" do
      before do
        stub_request(:get, "https://graph.facebook.com/v2.2/me?access_token=xxxx").
          to_return(:status => 200, :body => "")
      end

      it "loads the main page, requesting that the user sign into Campaign Monitor" do
        get "/",
          { "facebook" => { "user_id" => user_id } },
          { "rack.session" => { "fb_auth" => { "uid" => user_id }, "fb_token" => fb_token } }

        expect(last_request.env["rack.session"]["fb_auth"]).to eq({ "uid" => user_id })
        expect(last_request.env["rack.session"]["fb_token"]).to eq (fb_token)
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Log into your account")
      end
    end
  end

  describe "GET /saved/:page_id" do
    let(:page_id) { "7687687687" }

    context "when the user has not added the app to the page" do
      before do
        stub_request(:get, "http://graph.facebook.com/v2.2/7687687687").
          to_return(:status => 200, :body => %Q[{"id":"#{page_id}","has_added_app":false,"link":"https://www.facebook.com/pages/my-page/#{page_id}"}])
      end
      it "shows the settings saved page" do
        get "/saved/#{page_id}"

        expect(last_response.status).to eq(200)
        expect(last_response.body).to \
          include(%Q[top.location = "http://www.facebook.com/add.php?api_key=testapikey&pages=1&page=#{page_id}";])
      end
    end

    context "when the user has added the app to the page" do
      before do
        stub_request(:get, "http://graph.facebook.com/v2.2/7687687687").
          to_return(:status => 200, :body => %Q[{"id":"#{page_id}","has_added_app":true,"link":"https://www.facebook.com/pages/my-page/#{page_id}"}])
      end
      it "shows the settings saved page" do
        get "/saved/#{page_id}"

        expect(last_response.status).to eq(200)
        expect(last_response.body).to \
          include(%Q[top.location = "https://www.facebook.com/pages/my-page/#{page_id}";])
      end
    end
  end

  describe "POST /apikey" do
    context "when the Campaign Monitor API key is successfully retrieved" do
      before do
        stub_request(:get, "https://myusername:mypassword@api.createsend.com/api/v3/apikey.json?SiteUrl=https://myaccount.createsend.com").
          with(:headers => { "Content-Type" => "application/json; charset=utf-8" }).
          to_return(:status => 200,
            :headers => { "Content-Type" => "application/json; charset=utf-8" },
            :body => %Q[{ "ApiKey": "#{cm_api_key}" }])
        stub_request(:get, "https://graph.facebook.com/v2.2/me?access_token=xxxx").
          to_return(:status => 200, :body => %Q[{"id":"#{user_id}"}])
        stub_request(:get, "https://testapikey:x@api.createsend.com/api/v3/clients.json").
          to_return(
            :status => 200,
            :body => %Q[[{"ClientID":"clientid","Name":"client name"}]],
            :headers => { "Content-Type" => "application/json;charset=utf-8" })
      end

      it "returns a json payload containing account details" do
        post "/apikey", {
          "site_url" => "https://myaccount.createsend.com",
          "username" => "myusername",
          "password" => "mypassword"
        }, {
          "rack.session" => {
            "fb_auth" => { "uid" => user_id }, "fb_token" => fb_token
          }
        }

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq("application/json;charset=utf-8")
        expect(last_response.body).to \
          eq(%Q[{"account":{"api_key":"#{cm_api_key}","user_id":"#{user_id}","clients":[{"ClientID":"clientid","Name":"client name"}]}}])
      end
    end

    context "when the Campaign Monitor API key is not successfully retrieved" do
      before do
        stub_request(:get, "https://myusername:incorrectpassword@api.createsend.com/api/v3/apikey.json?SiteUrl=https://myaccount.createsend.com").
          with(:headers => { "Content-Type" => "application/json; charset=utf-8" }).
          to_return(:status => 400,
            :headers => { "Content-Type" => "application/json; charset=utf-8" },
            :body => %Q[{ "Code": 123, "Message": "Invalid username/password" }])
        stub_request(:get, "https://graph.facebook.com/v2.2/me?access_token=xxxx").
          to_return(:status => 200, :body => %Q[{"id":"#{user_id}"}])
      end

      it "returns a json payload containing an error message" do
        post "/apikey", {
          "site_url" => "https://myaccount.createsend.com",
          "username" => "myusername",
          "password" => "incorrectpassword"
        }, {
          "rack.session" => {
            "fb_auth" => { "uid" => user_id }, "fb_token" => fb_token
          }
        }

        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq("application/json;charset=utf-8")
        expect(last_response.body).to \
          eq(%Q[{"message":"Error getting API key..."}])
      end
    end
  end

  describe "GET /clients/:api_key" do
    context "when a call to the Campaign Monitor API succeeds" do
      before do
        stub_request(:get, "https://testapikey:x@api.createsend.com/api/v3/clients.json").
          to_return(
            :status => 200,
            :body => %Q[[{"ClientID":"clientid","Name":"client name"}]],
            :headers => { "Content-Type" => "application/json;charset=utf-8" })
      end

      it "gets the clients for the account matching the api key" do
        get "/clients/#{cm_api_key}"

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq("application/json;charset=utf-8")
        expect(last_response.body).to eq(%Q[[{"ClientID":"clientid","Name":"client name"}]])
      end
    end

    context "when a call to the Campaign Monitor API fails" do
      before do
        stub_request(:get, "https://testapikey:x@api.createsend.com/api/v3/clients.json").
          to_return(
            :status => 500,
            :body => %Q[[{"Code": 500,"Message":"Sorry."}]],
            :headers => { "Content-Type" => "application/json;charset=utf-8" })
      end

      it "gets an empty list" do
        get "/clients/#{cm_api_key}"

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq("application/json;charset=utf-8")
        expect(last_response.body).to eq("[]")
      end
    end
  end

  describe "GET /lists/:api_key/:client_id" do
    let(:client_id) { "43242343" }

    context "when a call to the Campaign Monitor API succeeds" do
      before do
        stub_request(:get, "https://testapikey:x@api.createsend.com/api/v3/clients/#{client_id}/lists.json").
          to_return(
            :status => 200,
            :body => %Q[[{"ListID":"listid","Name":"list name"}]],
            :headers => { "Content-Type" => "application/json;charset=utf-8" })
      end

      it "gets the subscriber lists for the client" do
        get "/lists/#{cm_api_key}/#{client_id}"

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq("application/json;charset=utf-8")
        expect(last_response.body).to eq(%Q[[{"ListID":"listid","Name":"list name"}]])
      end
    end

    context "when a call to the Campaign Monitor API fails" do
      before do
        stub_request(:get, "https://testapikey:x@api.createsend.com/api/v3/clients/#{client_id}/lists.json").
          to_return(
            :status => 500,
            :body => %Q[[{"Code": 500,"Message":"Sorry."}]],
            :headers => { "Content-Type" => "application/json;charset=utf-8" })
      end

      it "gets an empty list" do
        get "/lists/#{cm_api_key}/#{client_id}"

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq("application/json;charset=utf-8")
        expect(last_response.body).to eq("[]")
      end
    end
  end

  describe "GET /customfields/:api_key/:list_id" do
    let(:list_id) { "323231223" }
    context "when a call to the Campaign Monitor API succeeds" do
      before do
        stub_request(:get, "https://testapikey:x@api.createsend.com/api/v3/lists/#{list_id}/customfields.json").
          to_return(
            :status => 200,
            :body => %Q[[{"FieldName":"website","Key":"[website]","DataType":"Text","FieldOptions":[],"VisibleInPreferenceCenter":true}]],
            :headers => { "Content-Type" => "application/json;charset=utf-8" })
      end

      it "gets the custom fields for the list" do
        get "/customfields/#{cm_api_key}/#{list_id}"

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq("application/json;charset=utf-8")
        expect(last_response.body).to eq(%Q[[{"FieldName":"website","Key":"[website]","DataType":"Text","FieldOptions":[],"VisibleInPreferenceCenter":true}]])
      end
    end

    context "when a call to the Campaign Monitor API fails" do
      before do
        stub_request(:get, "https://testapikey:x@api.createsend.com/api/v3/lists/#{list_id}/customfields.json").
          to_return(
            :status => 500,
            :body => %Q[[{"Code": 500,"Message":"Sorry."}]],
            :headers => { "Content-Type" => "application/json;charset=utf-8" })
      end

      it "gets an empty list" do
        get "/customfields/#{cm_api_key}/#{list_id}"

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq("application/json;charset=utf-8")
        expect(last_response.body).to eq("[]")
      end
    end
  end

  describe "GET /tab" do
    context "when a page hasn't had a subscribe form set up" do
      it "shows that the page hasn't had a subscribe form set up yet" do
        get "/tab"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to \
          include("This page hasn't had a subscribe form set up yet")
      end
    end

    context "when a page has had a subscribe form set up" do
      let(:page_id) { "7687687687" }
      let(:client_id) { "testclientid" }
      let(:list_id) { "testlistid" }
      let(:account) {
        Account.first_or_create(:api_key => cm_api_key, :user_id => user_id)
      }
      let(:form) {
        Form.first_or_create(
          :account => account, :page_id => page_id, :client_id => client_id,
          :list_id => list_id, :intro_message => "Intro message!",
          :thanks_message => "Thanks!", :include_name => true)
      }

      before do
        # I'm not sure why this is needed, DataMapper...
        account.save
        form.save
      end

      it "shows the saved subscribe form" do
        get "/tab",
          { "facebook" => { "user_id" => user_id, "page" => { "id" => page_id } } }

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include(form.intro_message)
      end
    end
  end

  describe "POST /subscribe/:page_id" do
    context "when someone subscribes successfully" do
      let(:page_id) { "7687687687" }
      let(:client_id) { "testclientid" }
      let(:list_id) { "testlistid" }
      let(:account) {
        Account.first_or_create(:api_key => cm_api_key, :user_id => user_id)
      }
      let(:form) {
        Form.first_or_create(
          :account => account, :page_id => page_id, :client_id => client_id,
          :list_id => list_id, :intro_message => "Intro message!",
          :thanks_message => "Thanks!", :include_name => true)
      }

      before do
        # I'm not sure why this is needed, DataMapper...
        account.save
        form.save

        stub_request(:post, "https://testapikey:x@api.createsend.com/api/v3/subscribers/testlistid.json").
          with(
            :body => %Q[{"EmailAddress":"test@example.com","Name":"test subscriber","CustomFields":[{"Key":"[website]","Value":"https://example.com/"},{"Key":"[multiselect]","Value":"one"},{"Key":"[multiselect]","Value":"three"}],"Resubscribe":true,"RestartSubscriptionBasedAutoresponders":false}],
            :headers => { "Content-Type" => "application/json; charset=utf-8" }).
          to_return(:status => 200, :body => "test@example.com")
      end

      it "returns a json payload containing the success message" do
        post "/subscribe/#{page_id}", {
            "facebook" => { "user_id" => user_id, "page" => { "id" => page_id } },
            "name" => "test subscriber",
            "email" => "test@example.com",
            "cf-website" => "https://example.com/",
            "cf-multiselect" => [ "one", "three" ]
          }

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq("application/json;charset=utf-8")
        expect(last_response.body).to \
          eq(%Q[{"status":"success","message":"#{form.thanks_message}"}])
      end
    end

    context "when subscribing fails" do
      let(:page_id) { "7687687687" }
      let(:client_id) { "testclientid" }
      let(:list_id) { "testlistid" }
      let(:account) {
        Account.first_or_create(:api_key => cm_api_key, :user_id => user_id)
      }
      let(:form) {
        Form.first_or_create(
          :account => account, :page_id => page_id, :client_id => client_id,
          :list_id => list_id, :intro_message => "Intro message!",
          :thanks_message => "Thanks!", :include_name => true)
      }

      before do
        # I'm not sure why this is needed, DataMapper...
        account.save
        form.save

        stub_request(:post, "https://testapikey:x@api.createsend.com/api/v3/subscribers/testlistid.json").
          with(
            :body => %Q[{"EmailAddress":"not an email address","Name":"test subscriber","CustomFields":[{"Key":"[website]","Value":"https://example.com/"}],"Resubscribe":true,"RestartSubscriptionBasedAutoresponders":false}],
            :headers => { "Content-Type" => "application/json; charset=utf-8" }).
          to_return(:status => 400,
            :headers => { "Content-Type" => "application/json; charset=utf-8" },
            :body => %Q[{ "Code": 1, "Message": "Invalid email address" }])

      end

      it "returns a json payload containing the error details" do
        post "/subscribe/#{page_id}", {
            "facebook" => { "user_id" => user_id, "page" => { "id" => page_id } },
            "name" => "test subscriber",
            "email" => "not an email address",
            "cf-website" => "https://example.com/"
          }

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq("application/json;charset=utf-8")
        expect(last_response.body).to \
          eq(%Q[{"status":"error","message":"Sorry, there was a problem subscribing you to our list. Please try again."}])
      end
    end
  end

  describe "GET /ondeauth" do
    it "deletes any accounts associated with the fb user and responds with 200 OK" do
      get "/ondeauth", { "facebook" => { "user_id" => user_id } }

      accounts = Account.all(:user_id => user_id)
      expect(accounts).to eq([])
      expect(last_response.status).to eq(200)
    end
  end

  describe "GET /auth/failure" do
    it "clears the session and redirects to /" do
      get "/auth/failure"

      expect(last_request.env["rack.session"]["fb_auth"]).to be_nil
      expect(last_request.env["rack.session"]["fb_token"]).to be_nil
      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq("http://example.org/")
    end
  end

  describe "GET /logout" do
    it "clears the session and redirects to /" do
      get "/logout"

      expect(last_request.env["rack.session"]["fb_auth"]).to be_nil
      expect(last_request.env["rack.session"]["fb_token"]).to be_nil
      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq("http://example.org/")
    end
  end

  describe "GET /privacy" do
    it "shows the privacy page" do
      get "/privacy"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to \
        include("The Campaign Monitor Subscribe Form app respect's the privacy of people who use it")
    end
  end

  describe "GET /nothingtoseehere" do
    it "shows the app's 404 Not Found page" do
      get "/nothingtoseehere"
      expect(last_response.status).to eq(404)
      expect(last_response.body).to \
        include("We don't recognise that as part of Campaign Monitor Subscribe Form - sorry!")
    end
  end

  describe "GET /boom" do
    it "shows the app's 500 Server Error page" do
      expect do
        get "/boom"
        expect(last_response.status).to eq(500)
        expect(last_response.body).to \
          include("We're really sorry that there's something wrong with Campaign Monitor Subscribe Form")
      end.to raise_error
    end
  end

  describe "GET /reset.css" do
    it "serves the reset.css stylesheet" do
      get "/reset.css"
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq("text/css;charset=utf-8")
    end
  end

  describe "GET /cm.css" do
    it "serves the cm.css stylesheet" do
      get "/cm.css"
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq("text/css;charset=utf-8")
    end
  end

  describe "GET /fb.css" do
    it "serves the fb.css stylesheet" do
      get "/fb.css"
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq("text/css;charset=utf-8")
    end
  end
end
