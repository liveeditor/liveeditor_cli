require 'live_editor/cli/validators/validator'

module LiveEditor
  module CLI
    module Validators
      class ConfigValidator < Validator
        # Returns an array of errors if any were found with `/theme.json`.
        def valid?
          # Grab location of /config.json.
          config_loc = LiveEditor::CLI::theme_root_dir + '/config.json'

          # Validate existence of config.json.
          if File.exist?(config_loc)
            # Validate format of config.json.
            begin
              config = JSON.parse(File.read(config_loc))
            rescue Exception => e
              self.messages << {
                type: :error,
                message: 'The file at `/config.json` does not contain valid JSON markup.'
              }

              return false
            end

            # Validate presence of `admin_domain` attribute.
            if config['admin_domain'].blank? || config['admin_domain'] == '.liveeditorapp.com'
              self.messages << {
                type: :error,
                message: "The file at `/config.json` must contain an `admin_domain` attribute."
              }
            end
          # No config.json.
          else
            self.messages << {
              type: :error,
              message: '`/config.json` has not yet been created.'
            }
          end

          self.errors.size == 0
        end
      end
    end
  end
end
