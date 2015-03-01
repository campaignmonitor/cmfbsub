require "helper"

set :environment, :test

describe "The Campaign Monitor Subscribe Form app" do
  let(:app) { Sinatra::Application }
  let(:user_id) { "7654321" }
  let(:fb_token) { "xxxx" }

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

end
