module LiveEditor
  module Cli
    module Validators
      class ConfigValidator
        # Attributes
        attr_reader :errors

        # Constructor.
        def initialize
          @errors = []
        end

        # Returns an array of errors if any were found with `/theme.json`.
        def valid?
          # Grab location of /config.json.
          config_loc = LiveEditor::Cli::theme_root_dir + '/config.json'

          # Validate existence of config.json.
          if File.exist?(config_loc)
            # Validate format of config.json.
            begin
              config = JSON.parse(File.read(config_loc))
            rescue Exception => e
              @errors << {
                type: :error,
                message: 'The file at `/config.json` does not contain valid JSON markup.'
              }

              return false
            end

            # Validate presence of `api_key`, `secret_key`, and `admin_domain` attributes.
            ['api_key', 'secret_key', 'admin_domain'].each do |key|
              if config[key].blank?
                a_an = key.start_with?('a') ? 'an' : 'a'

                @errors << {
                  type: :error,
                  message: "The file at `/config.json` must contain #{a_an} `#{key}` attribute."
                }
              end
            end
          # No config.json.
          else
            @errors << {
              type: :notice,
              messag: '`/config.json` has not yet been created.'
            }
          end

          @errors.select { |error| error[:type] == :error }.size == 0
        end
      end
    end
  end
end
