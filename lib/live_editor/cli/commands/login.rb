module LiveEditor
  module CLI
    module Commands
      module Login
        def self.included(thor)
          thor.class_eval do
            desc 'login', 'Log in to the Live Editor service specified in `config.json`.'
            method_option :email, type: :string, desc: 'Email address to use for login'
            method_option :password, type: :string, desc: 'Password to use for login'
            def login
              # Fail if we're not within a theme folder structure.
              theme_root = LiveEditor::CLI::theme_root_dir! || return

              say ''
              say 'Logging in to Live Editor...'

              # Validate config.
              config_validator = LiveEditor::CLI::Validators::ConfigValidator.new
              unless config_validator.valid?
                display_validator_messages(config_validator.errors)
                return
              end

              # Grab config.
              config = LiveEditor::CLI::config_config.config
              say "Connecting to #{config['admin_domain']}."
              say ''

              # Ask for email and password from user.
              email = if options[:email].present?
                say "Email: #{options[:email]}"
                options[:email]
              else
                email = ask('Email:')
              end

              password = if options[:password].present?
                say "Password: #{options[:password].gsub(/./, '*')}"
                options[:password]
              else
                ask('Password (typing will be hidden):', echo: false)
              end

              say ''
              say ''

              # Halt if no email or password were provided.
              unless email.present? && password.present?
                display_validator_messages [{
                  type: :error,
                  message: 'Enter both an email address and password.'
                }]

                return 1
              end

              LiveEditor::CLI::configure_client!

              oauth = LiveEditor::API::OAuth.new
              response = oauth.login(email, password)

              if response.success?
                data = response.parsed_body
                LiveEditor::CLI::store_credentials(config['admin_domain'], email, data['access_token'], data['refresh_token'])
                say("You are now logged in to the admin at `#{config['admin_domain']}`.", :green)
              elsif response.errors.any?
                say('ERROR: ' + response.errors.first['detail'], :red)
              end
            end
          end
        end
      end
    end
  end
end
