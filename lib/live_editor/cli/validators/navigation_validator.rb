module LiveEditor
  module Cli
    module Validators
      class NavigationValidator
        # Attributes
        attr_reader :errors

        # Constructor.
        def initialize
          @errors = []
        end

        # Returns whether or not any errors were found within
        # `/navigation/navigation.json` (if it even exists).
        #
        # An array of errors and notices will also be stored in the `errors`
        # attribute after running this method.
        def valid?
          # Grab location of /navigation folder.
          nav_folder_loc = LiveEditor::Cli::theme_root_dir + '/navigation'

          # navigation folder is optional.
          return true unless File.exist?(nav_folder_loc)

          # Location of /navigation/navigation.json.
          nav_config_loc = nav_folder_loc + '/navigation.json'

          # navigation.json is optional too.
          return true unless File.exist?(nav_config_loc)

          # Validate format of navigation.json.
          # Returns `false` on failure because we can't continue further unless
          # this is valid.
          begin
            nav_config = JSON.parse(File.read(nav_config_loc))
          rescue Exception => e
            self.errors << {
              type: :error,
              message: 'The file at `/navigation/navigation.json` does not contain valid JSON markup.'
            }

            return false
          end

          # Validate presence of root `navigation` attribute.
          unless nav_config['navigation'].present? && nav_config['navigation'].is_a?(Array)
            self.errors << {
              type: :error,
              message: 'The file at `/navigation/navigation.json` must contain a root `navigation` attribute containing an array.'
            }

            return false
          end

          # Validate each navigation menu's attributes.
          nav_config['navigation'].each_with_index do |nav_config, index|
            # `title` is required.
            if nav_config['title'].blank?
              self.errors << {
                type: :error,
                message: "The navigation menu in position #{index + 1} within the file at `/navigation/navigation.json` does not have a valid `title`."
              }
            end

            # Matching Liquid template must exist.
            filename = nav_config['filename'] || nav_config['var_name'] || LiveEditor::Cli::naming_for(nav_config['title'])[:var_name]

            if filename.present?
              filename += '_navigation.liquid'

              unless File.exist?(nav_folder_loc + '/' + filename)
                self.errors << {
                  type: :error,
                  message: "The navigation menu in position #{index + 1} is missing its matching Liquid template: `/navigation/#{filename}`."
                }
              end
            end
          end

          self.errors.size == 0
        end
      end
    end
  end
end
