require "helper"

describe "Rack::Facebook" do
  let(:fb_token) { "xxxx" }
  let(:app) { ->(env) { [200, env, "hi"] } }
  let(:facebook) { Rack::Facebook.new(app, :secret => ENV["APP_SECRET"]) }

  describe "#call" do
    let(:url) { "http://example.org/" }

    context "when the signature in the signed_request is invalid" do
      let(:signed_request) { "XHhFRTRBXHgxNFx4REM3XHhGOVx4ODVceEJCXHhCQ1JLZS9ceEExXHhEMVx0.eyJvYXV0aF90b2tlbiI6Inh4eHgiLCJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTE4NDA0MDAsImlzc3VlZF9hdCI6MTI5MTgzNjgwMCwidXNlcl9pZCI6Ijc2NTQzMjEifQ==" }
      let(:env) do
        Rack::MockRequest.env_for(
          url, :method => "POST", :params => {
            "signed_request" => signed_request } )
      end

      it "switches the method to GET but returns a 400 Bad Request" do
        code, headers, result = facebook.call env
        expect(env["REQUEST_METHOD"]).to eq("GET")
        expect(code).to eq(400)
        expect(result.body).to eq(["Invalid signature"])
      end
    end

  end
end
