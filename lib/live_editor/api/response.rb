module LiveEditor
  module API
    class ParseError; end

    class Response
      # Attributes
      attr_accessor :response, :refreshed_oauth

      # Constructor.
      def initialize(response, refreshed_oauth = nil)
        @response = response
        @refreshed_oauth = refreshed_oauth
      end

      # Returns whether or not the response is an error.
      def error?
        self.response.is_a?(Net::HTTPClientError) || self.response.is_a?(Net::HTTPServerError)
      end

      # Returns an array of errors if available.
      def errors
        if self.error? && self.json_api? && self.parsed_body.has_key?('errors')
          self.parsed_body['errors']
        elsif self.error? && self.json? && self.parsed_body.has_key?('error')
          [{ 'detail' => self.parsed_body['error'] }]
        else
          []
        end
      end

      # Returns whether or not the response has JSON-formatted content.
      def json?
        parsed_body_valid?
      end

      # Returns whether or not the response has JSON API-formatted content.
      def json_api?
        self.response.content_type.present? &&
          self.response.content_type.start_with?('application/vnd.api+json') &&
          self.json?
      end

      # Parses response body and caches it so the parsing doesn't keep happening
      # and happening on multiple calls to this method. If the response body
      # isn't valid JSON, then this method returns a
      #{ }`LiveEditor::API::ParserError`.
      def parsed_body
        @parsed_body ||= JSON.parse(self.response.body)
      rescue JSON::ParserError, TypeError
        @parsed_body = LiveEditor::API::ParseError
      end

      # Returns whether or not OAuth credentials were refreshed during the
      # request.
      def refreshed_oauth?
        self.refreshed_oauth.present?
      end

      # Returns whether or not the response was successful.
      def success?
        self.response.is_a?(Net::HTTPSuccess) || self.response.is_a?(Net::HTTPRedirection)
      end

    private

      # Returns whether or not the JSON-parsed body contains valid data.
      def parsed_body_valid?
        parsed_body != LiveEditor::API::ParseError
      end
    end
  end
end
