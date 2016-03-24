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
        LiveEditor::API::client.post('/oauth/token.json', authorize: false, json_api: false, form_data: {
          grant_type: 'password',
          username: email,
          password: password
        })
      end

      # Requests an access token for a given refresh token.
      #
      # Arguments:
      #
      # -  `refresh_token` - Refresh token.
      def request_access_token(refresh_token)
        LiveEditor::API::client.post('/oauth/token', authorize: false, json_api: false, form_data: {
            grant_type: 'refresh_token',
            refresh_token: refresh_token
        })
      end
    end
  end
end
