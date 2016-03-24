require 'net/http'

module LiveEditor
  module API
    class OAuth
      # Log in to the Live Editor service with email and password. Returns hash
      # containing OAuth data: `access_token`, `refresh_token`, etc.).
      #
      # Arguments:
      #
      # -  `email` - Email to login with.
      # -  `password` - Password to login with.
      def login(email, password)
        client = LiveEditor::API::client
        uri = client.uri('/oauth/token.json')
        request = Net::HTTP::Post.new(uri)

        request.set_form_data 'grant_type' => 'password',
                              'username' => email,
                              'password' => password

        response = Net::HTTP.start(uri.hostname, client.port) do |http|
          http.request(request)
        end

        LiveEditor::API::Response.new(response)
      end

      # Requests an access token for a given refresh token.
      #
      # Arguments:
      #
      # -  `refresh_token` - Refresh token.
      def request_access_token(refresh_token)
        client = LiveEditor::API::client

        response = client.post('/oauth/token', authorize: false, json_api: false, form_data: {
            grant_type: 'refresh_token',
            refresh_token: refresh_token
        })

        LiveEditor::API::Response.new(response)
      end
    end
  end
end
