module Rapyd
  class ApiRequest

    class << self

      def api_url(path = "")
        Rapyd.api_base + path
      end

      def request(method, path, params = {}, headers = {})
        request_opts = {
          url: api_url(path),
          method: method,
          headers: request_headers(method, path, params).update(headers),
        }

        case method
        when :get
          request_opts[:headers].update(params: params)
        else
          request_opts.update(payload: params.to_json)
        end

        response = execute_request(request_opts)
        parse(response)
      end

      private

      def execute_request(request_opts)
        begin
          response = RestClient::Request.execute(request_opts)
        rescue => e
          response = handle_error(e, request_opts)
        end
        response
      end

      def handle_error(e, request_opts)
        if e.is_a?(RestClient::ExceptionWithResponse) && e.response
          handle_api_error(e.response)
        else
          handle_restclient_error(e, request_opts)
        end
      end

      def handle_api_error(resp)
        error_obj = parse(resp).with_indifferent_access
        error_body = error_obj["status"]
        error_code = error_body.try(:[], "error_code")
        error_message = (error_body.try(:[], "message") || error_obj.to_s)

        error_klass = Rapyd::ERROR_CLASS_MAPPING.select{|key, values| values.include?(error_code)}.keys[0]
        if error_klass.present?
          raise "Rapyd::#{error_klass}".constantize.new(error_params(error_message, resp, error_obj))
        else
          raise Rapyd::RapydError.new(error_params(error_message, resp, error_obj))
        end
      end

      def handle_restclient_error(e, request_opts)
        connection_message = "Please check your internet connection and try again. "

        case e
        when RestClient::RequestTimeout
          message = "Could not connect to Rapyd (#{request_opts[:url]}). #{connection_message}"
        when RestClient::ServerBrokeConnection
          message = "The connection to the server (#{request_opts[:url]}) broke before the " \
            "request completed. #{connection_message}"
        else
          message = "Unexpected error communicating with Rapyd. "
        end

        raise Rapyd::ApiConnectionError.new({message: "#{message} \n\n (Error: #{e.message})"})
      end

      def handle_parse_error(rcode, rbody)
        Rapyd::ParseError.new({
          message: "Not able to parse because of invalid response object from API: #{rbody.inspect} (HTTP response code was #{rcode})",
          http_status: rcode,
          http_body: rbody
        })
      end

      def error_params(error, resp, error_obj)
        {
          message: error,
          http_status: resp.code,
          http_body: resp.body,
          json_body: error_obj,
          http_headers: resp.headers
        }
      end

      def parse(response)
        begin
          response = JSON.parse(response.body)
        rescue JSON::ParserError
          raise handle_parse_error(response.code, response.body)
        end
        response
      end

      def request_headers(method, path, params)
        salt = generate_salt
        timestamp = Time.now.to_i.to_s

        headers = {
          "content-type" => "application/json",
          "salt" => salt,
          "timestamp" => timestamp,
          "access_key" => Rapyd.access_key,
        }

        headers["signature"] = signature(
          method: method,
          path: path,
          salt: salt,
          timestamp: timestamp,
          params: params,
        )

        headers
      end

      def signature(method:, path:, salt:, timestamp:, params:)
        to_sign = "#{method.to_s}#{path}#{salt}#{timestamp}#{Rapyd.access_key}#{Rapyd.secret_key}"
        to_sign << params.to_json if ((method != :get) && params.present?)
        mac = OpenSSL::HMAC.hexdigest("SHA256", Rapyd.secret_key, to_sign)
        Base64.urlsafe_encode64(mac)
      end

      def generate_salt
        o = [('a'..'z')].map(& :to_a).flatten
        (0...8).map { o[rand(o.length)] }.join
      end
    end
  end
end