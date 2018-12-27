require 'securerandom'

module Rack
  class RequestId

    HEADER_KEY = 'X-Request-Id'

    def initialize(app, opts = {})
      @app = app
      @storage = opts[:storage] || proc { Thread.current }
      @id_generator = opts[:id_generator] || proc { SecureRandom.hex(16) }
    end

    def call(env)
      storage = @storage.respond_to?(:call) ? @storage.call : @storage
      request = Rack::Request.new(env)

      if request_id = request.get_header(HEADER_KEY)
        storage[:request_id] = request_id
      else
        storage[:request_id] = @id_generator.call
        request.set_header(HEADER_KEY, storage[:request_id])
      end

      status, headers, body = @app.call(env)

      headers[HEADER_KEY] ||= storage[:request_id]
      [status, headers, body]
    end
  end
end
