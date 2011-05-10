require 'openssl'
require 'base64'
require 'yajl'

module Rack
  # Custom middleware for a Facebook canvas app
  class Facebook
    def initialize(app, options={})
      @app = app
      @options = options
    end

    def secret
      @options.fetch(:secret)
    end
    
    def call(env)
      request = Rack::Request.new(env)
      if request.POST['signed_request']
        env["REQUEST_METHOD"] = 'GET'
        signed_request = request.params.delete('signed_request')
        unless signed_request.nil?
          signature, signed_params = signed_request.split('.')
          unless signed_request_is_valid?(secret, signature, signed_params)
            return Rack::Response.new(["Invalid signature"], 400).finish
          end
          signed_params = Yajl::Parser.new.parse(base64_url_decode(signed_params))
          request.params['facebook'] = {}
          signed_params.each do |k,v|
            request.params['facebook'][k] = v
          end
        end
      end
      return @app.call(env)
    end

    private
      def signed_request_is_valid?(secret, signature, params)
        signature = base64_url_decode(signature)
        expected_signature = OpenSSL::HMAC.digest('SHA256', secret, params.tr("-_", "+/"))
        return signature == expected_signature
      end

      def base64_url_decode(str)
        str = str + "=" * (6 - str.size % 6) unless str.size % 6 == 0
        return Base64.decode64(str.tr("-_", "+/"))
      end
  end
end
