require "helper"

describe "Rack::Facebook" do
  let(:user_id) { "7654321" }
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

    context "when the signature in the signed_request is valid" do
      let(:signed_request) { "bBYyOfNV9htXZo9E2utxFfyrfIt+niX2VvtC0yczCUY=\n.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjE0MjYwNzg4\nMDAsImlzc3VlZF9hdCI6MTQyNjA3NDc5Mywib2F1dGhfdG9rZW4iOiJ4eHh4\nIiwidXNlciI6eyJjb3VudHJ5IjoiZGUiLCJsb2NhbGUiOiJlbl9HQiIsImFn\nZSI6eyJtaW4iOjIxfX0sInVzZXJfaWQiOiI3NjU0MzIxIn0=\n" }
      let(:env) do
        Rack::MockRequest.env_for(
          url, :method => "POST", :params => {
            "signed_request" => signed_request } )
      end

      it "switches the method to GET and successfully parses the signed_request" do
        code, headers, body = facebook.call env
        expect(env["REQUEST_METHOD"]).to eq("GET")
        expect(code).to eq(200)
        expect(body).to eq("hi")

        fb = env["rack.request.form_hash"]["facebook"]
        expect(fb["algorithm"]).to eq("HMAC-SHA256")
        expect(fb["expires"]).to eq(1426078800)
        expect(fb["issued_at"]).to eq(1426074793)
        expect(fb["oauth_token"]).to eq(fb_token)
        expect(fb["user_id"]).to eq(user_id)
      end
    end

  end
end
