require 'live_editor/cli/validators/validator'

module LiveEditor
  module CLI
    module Validators
      class LayoutsValidator < Validator
        # Returns whether or not any errors were found within
        # `/layouts/layouts.json`.
        #
        # An array of errors and notices will also be stored in the `errors`
        # attribute after running this method.
        def valid?
          # Grab location of /layouts folder.
          layouts_folder_loc = LiveEditor::CLI::theme_root_dir + '/layouts'

          unless File.exist?(layouts_folder_loc)
            self.messages << {
              type: :error,
              message: 'The folder at `/layouts` does not exist.'
            }

            return false
          end

          # Validate existence of /layouts/layouts.json.
          layouts_config_loc = layouts_folder_loc + '/layouts.json'

          if File.exist?(layouts_config_loc)
            layouts_config = LiveEditor::CLI::layouts_config

            # Validate format of `layouts.json`.
            unless layouts_config.parsed?
              self.messages << {
                type: :error,
                message: 'The file at `/layouts/layouts.json` does not contain valid JSON markup.'
              }

              return false
            end

            config = layouts_config.config

            # Validate presence of root `layouts` attribute.
            unless config['layouts'] && config['layouts'].is_a?(Array)
              self.messages << {
                type: :error,
                message: 'The file at `/layouts/layouts.json` must contain a root `layouts` attribute containing an array.'
              }

              return false
            end

            # Validate each layout's attributes.
            layouts_config.layouts.each_with_index do |layout_config, index|
              # Title is required.
              if layout_config['title'].blank?
                self.messages << {
                  type: :error,
                  message: "The layout in position #{index + 1} within the file at `/layouts/layouts.json` does not have a valid title."
                }
              end

              # Unique is optional but must be boolean.
              if layout_config['unique'].present? && ![true, false].include?(layout_config['unique'])
                self.messages << {
                  type: :error,
                  message: "The layout in position #{index + 1} within the file at `/layouts/layouts.json` does not have a valid value for `unique`."
                }
              end

              # File name must have matching liquid file.
              if layout_config['title'].present? || layout_config['file_name'].present?
                file_name = layout_config['file_name'] ? layout_config['file_name'] : LiveEditor::CLI::naming_for(layout_config['title'])[:var_name]
                file_name += '_layout.liquid'

                unless File.exist?(layouts_folder_loc + '/' + file_name)
                  self.messages << {
                    type: :error,
                    message: "The layout in position #{index + 1} is missing its matching Liquid template: `#{file_name}`."
                  }
                end
              end

              # Regions must be an array (if set).
              if layout_config['regions'] && !layout_config['regions'].is_a?(Array)
                self.messages << {
                  type: :error,
                  message: "The layout in position #{index + 1}'s `regions` attribute must be an array."
                }
              # If we have an array, continue on to validate regions.
              elsif layout_config['regions']
                content_templates_config = LiveEditor::CLI::content_templates_config

                layout_config['regions'].each_with_index do |region_config, r_index|
                  region_validator = LiveEditor::CLI::Validators::RegionValidator.new region_config, index, r_index,
                                                                                      content_templates_config

                  self.messages.concat(region_validator.messages) unless region_validator.valid?
                end
              end
            end
          # No `layouts.json`.
          else
            self.messages << {
              type: :error,
              message: '`/layouts/layouts.json` does not exist.'
            }
          end

          self.errors.size == 0
        end
      end
    end
  end
end
