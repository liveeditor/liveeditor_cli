module LiveEditor
  module Cli
    module Validators
      class ConfigSampleValidator
        # Attributes
        attr_reader :errors

        # Constructor.
        def initialize
          @errors = []
        end

        # Returns an array of errors if any were found with `/config.sample.json`.
        def valid?
          # Grab location of /config.sample.json.
          config_sample_loc = LiveEditor::Cli::theme_root_dir + '/config.json.sample'

          # Validate existence of config.sample.json.
          if File.exist?(config_sample_loc)
            # Validate format of config.sample.json.
            begin
              sample_config = JSON.parse(File.read(config_sample_loc))
            rescue Exception => e
              @errors << {
                type: :notice,
                message: 'The file at `/config.json.sample` does not contain valid JSON markup.'
              }

              return true
            end

            # Validate presence of `api_key`, `secret_key`, and `admin_domain` attributes.
            ['api_key', 'secret_key', 'admin_domain'].each do |key|
              if sample_config[key].present?
                @errors << {
                  type: :notice,
                  message: "It is not recommended to store `#{key}` in the `/config.sample.json` file."
                }
              end
            end
          end

          @errors.select { |error| error[:type] == :error }.size == 0
        end
      end
    end
  end
end
