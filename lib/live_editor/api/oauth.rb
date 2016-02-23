require 'net/http'

module LiveEditor
  module API
    class OAuth
      # Log in to the Live Editor service with email and password. Returns hash
      # containing OAuth data: `access_token`, `refresh_token`, etc.).
      def login(email, password)
        uri = LiveEditor::API::uri('/oauth/token.json')
        request = Net::HTTP::Post.new(uri)

        request.set_form_data 'grant_type' => 'password',
                              'username' => email,
                              'password' => password

        port = ![80, 443].include?(uri.port) ? uri.port : nil

        response = Net::HTTP.start(uri.hostname, port) do |http|
          http.request(request)
        end

        case response
        when Net::HTTPSuccess then
          JSON.parse(response.body)
        when Net::HTTPUnauthorized then
          JSON.parse(response.body)
        else
          { 'error' => 'There was an error connecting to the Live Editor API.' }
        end
      end
    end
  end
end
