module Rack
  class Facebook
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Request.new(env)
      
      if request.POST['signed_request']
        
        
        p "here: #{request.POST['signed_request']}"
        
        env["REQUEST_METHOD"] = 'GET'
      end
      
      return @app.call(env)
    end
  end
end
