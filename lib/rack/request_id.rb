require 'securerandom'

module Rack
  class RequestId

    ENV_KEY = 'HTTP_X_REQUEST_ID'
    HEADER_KEY = 'X-Request-Id'

    def initialize(app, opts = {})
      @app = app
      @storage = opts[:storage] || proc { Thread.current }
      @id_generator = opts[:id_generator] || proc { SecureRandom.hex(16) }
    end

    def call(env)
      storage = @storage.respond_to?(:call) ? @storage.call : @storage
      request = Rack::Request.new(env)

      request_id = env[ENV_KEY] || request.get_header(HEADER_KEY) || @id_generator.call

      storage[:request_id] = request_id
      request.set_header(HEADER_KEY, request_id)
      env[ENV_KEY] = request_id

      status, headers, body = @app.call(env)
      headers[HEADER_KEY] ||= request_id

      [status, headers, body]
    end
  end
end
