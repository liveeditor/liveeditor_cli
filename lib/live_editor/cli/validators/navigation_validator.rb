require 'live_editor/cli/validators/validator'

module LiveEditor
  module CLI
    module Validators
      class NavigationValidator < Validator
        # Returns whether or not any errors were found within
        # `/navigation/navigation.json` (if it even exists).
        #
        # An array of errors and notices will also be stored in the `errors`
        # attribute after running this method.
        def valid?
          # Grab location of /navigation folder.
          nav_folder_loc = LiveEditor::CLI::theme_root_dir + '/navigation'

          # navigation folder is optional.
          return true unless File.exist?(nav_folder_loc)

          # Location of /navigation/navigation.json.
          nav_config_loc = nav_folder_loc + '/navigation.json'

          # navigation.json is optional too.
          return true unless File.exist?(nav_config_loc)

          nav_config = LiveEditor::CLI::navigation_config

          # Validate format of navigation.json.
          # Returns `false` on failure because we can't continue further unless
          # this is valid.
          unless nav_config.parsed?
            self.messages << {
              type: :error,
              message: 'The file at `/navigation/navigation.json` does not contain valid JSON markup.'
            }

            return false
          end

          config = nav_config.config

          # Validate presence of root `navigation` attribute.
          unless config['navigation'].present? && config['navigation'].is_a?(Array)
            self.messages << {
              type: :error,
              message: 'The file at `/navigation/navigation.json` must contain a root `navigation` attribute containing an array.'
            }

            return false
          end

          # Validate each navigation menu's attributes.
          nav_config.navigation.each_with_index do |nav_config, index|
            # `title` is required.
            if nav_config['title'].blank?
              self.messages << {
                type: :error,
                message: "The navigation menu in position #{index + 1} within the file at `/navigation/navigation.json` does not have a valid `title`."
              }
            end

            # Matching Liquid template must exist.
            file_name = nav_config['file_name'] || nav_config['var_name'] || LiveEditor::CLI::naming_for(nav_config['title'])[:var_name]

            if file_name.present?
              file_name += '_navigation.liquid'

              unless File.exist?(nav_folder_loc + '/' + file_name)
                self.messages << {
                  type: :error,
                  message: "The navigation menu in position #{index + 1} is missing its matching Liquid template: `/navigation/#{file_name}`."
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
