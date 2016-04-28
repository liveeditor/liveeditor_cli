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
            # Validate format of layouts.json.
            begin
              layouts_config = JSON.parse(File.read(layouts_config_loc))
            rescue Exception => e
              self.messages << {
                type: :error,
                message: 'The file at `/layouts/layouts.json` does not contain valid JSON markup.'
              }

              return false
            end

            # Validate presence of root `layouts` attribute.
            unless layouts_config['layouts'] && layouts_config['layouts'].is_a?(Array)
              self.messages << {
                type: :error,
                message: 'The file at `/layouts/layouts.json` must contain a root `layouts` attribute containing an array.'
              }

              return false
            end

            # Validate each layout's attributes.
            layouts_config['layouts'].each_with_index do |layout_config, index|
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
                layout_config['regions'].each_with_index do |region_config, r_index|
                  # Title is required.
                  if region_config['title'].blank?
                    self.messages << {
                      type: :error,
                      message: "The layout in position #{index + 1}'s region in position #{r_index + 1} must have a `title`."
                    }
                  end

                  if region_config['content_templates'].present?
                    # Content templates must be an array.
                    if !region_config['content_templates'].is_a?(Array)
                      self.messages << {
                        type: :error,
                        message: "The layout in position #{index + 1}'s region in position #{r_index + 1} has an invalid `content_templates` attribute: must be an array."
                      }
                    # Content templates must be real content templates
                    else
                      region_config['content_templates'].each do |content_template_var_name|
                        # Check if it's a base content type.
                        if LiveEditor::API::Themes::BASE_CONTENT_TEMPLATE_VAR_NAMES.include?(content_template_var_name)
                          matching_template_found = true
                        # Otherwise, search custom types.
                        else
                          templates_config = LiveEditor::CLI::content_templates_config

                          matching_templates = templates_config.content_templates.select do |matching_template|
                            if matching_template['var_name'].present? && matching_template['var_name'] == content_template_var_name
                              true
                            else
                              var_name = LiveEditor::CLI::naming_for(matching_template['title'])[:var_name]
                              var_name == content_template_var_name
                            end
                          end

                          matching_template_found = matching_templates.any?
                        end

                        unless matching_template_found
                          self.messages << {
                            type: :error,
                            message: "The layout in position #{index + 1}'s region in position #{r_index + 1} has an invalid `content_template`: `#{content_template_var_name}`."
                          }
                        end
                      end
                    end
                  end

                  # Max num content must be an integer (if present).
                  if region_config['max_num_content'].present? && !region_config['max_num_content'].is_a?(Integer)
                    self.messages << {
                      type: :error,
                      message: "The layout in position #{index + 1}'s region in position #{r_index + 1} has an invalid `max_num_content` attribute: must be an integer."
                    }
                  end
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
