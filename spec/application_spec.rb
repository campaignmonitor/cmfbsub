require "helper"

set :environment, :test

describe "The Campaign Monitor Subscribe Form app" do
  let(:app) { Sinatra::Application }
  let(:client_id) { ENV["GITHUB_CLIENT_ID"] }
  let(:client_secret) { ENV["GITHUB_CLIENT_SECRET"] }

  describe "GET /" do
    context "when the app is not authorised" do
      it "redirects to request authorisation" do
        get "/"
        expect(last_response.status).to eq(302)
        expect(last_response.location).to eq("http://example.org/auth/facebook")
      end
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

end
