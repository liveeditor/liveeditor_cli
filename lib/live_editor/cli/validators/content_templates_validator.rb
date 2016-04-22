require 'live_editor/cli/validators/validator'

module LiveEditor
  module CLI
    module Validators
      class ContentTemplatesValidator < Validator
        # Returns whether or not any errors were found within
        # `/content_templates/content_templates.json` (if it even exists).
        #
        # An array of errors and notices will also be stored in the `errors`
        # attribute after running this method.
        def valid?
          # Grab location of /content_templates folder.
          templates_folder_loc = LiveEditor::CLI::theme_root_dir + '/content_templates'

          # content_templates folder is optional.
          return true unless File.exist?(templates_folder_loc)

          # Location of /content_templates/content_templates.json.
          templates_config_loc = templates_folder_loc + '/content_templates.json'

          # content_templates.json is optional too.
          return true unless File.exist?(templates_config_loc)

          # Validate format of content_templates.json.
          # Returns false on failure because we can't continue further unless this is valid.
          begin
            templates_config = JSON.parse(File.read(templates_config_loc))
          rescue Exception => e
            self.messages << {
              type: :error,
              message: 'The file at `/content_templates/content_templates.json` does not contain valid JSON markup.'
            }

            return false
          end

          # Validate presence of root `content_templates` attribute.
          # Returns false on failure because we can't continue further unless this is valid.
          unless templates_config['content_templates'].present? && templates_config['content_templates'].is_a?(Array)
            self.messages << {
              type: :error,
              message: 'The file at `/content_templates/content_templates.json` must contain a root `content_templates` attribute containing an array.'
            }

            return false
          end

          # Validate each content templates's attributes.
          templates_config['content_templates'].each_with_index do |template_config, index|
            validate_content_template(template_config, index, templates_folder_loc)
          end

          self.errors.size == 0
        end

      private

        # Validates block JSON structure.
        def validate_block(block, content_template_index, block_index)
          # Title is required.
          if block['title'].blank?
            self.messages << {
              type: :error,
              message: "The content template in position #{content_template_index + 1}'s block in position #{block_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid `title`."
            }
          end

          # Data type is required.
          if block['data_type'].blank?
            self.messages << {
              type: :error,
              message: "The content template in position #{content_template_index + 1}'s block in position #{block_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid `data_type`."
            }
          end

          # Required is optional but must be boolean if set.
          if block['required'].present? && ![true, false].include?(block['required'])
            self.messages << {
              type: :error,
              message: "The content template in position #{content_template_index + 1}'s block in position #{block_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `required`."
            }
          end

          # `inline` is optional but must be boolean if set.
          if block['inline'].present? && ![true, false].include?(block['inline'])
            self.messages << {
              type: :error,
              message: "The content template in position #{content_template_index + 1}'s block in position #{block_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `inline`."
            }
          end
        end

        # Validates content template JSON structure.
        def validate_content_template(content_template, index, templates_folder_loc)
          # Title is required.
          if content_template['title'].blank?
            self.messages << {
              type: :error,
              message: "The content template in position #{index + 1} within the file at `/content_templates/content_templates.json` does not have a valid `title`."
            }
          end

          # Unique is optional but must be boolean.
          if content_template['unique'].present? && ![true, false].include?(content_template['unique'])
            self.messages << {
              type: :error,
              message: "The content template in position #{index + 1} within the file at `/content_templates/content_templates.json` does not have a valid value for `unique`."
            }
          end

          # Blocks must be an array (if set).
          if content_template['blocks'].present? && !content_template['blocks'].is_a?(Array)
            self.messages << {
              type: :error,
              message: "The content template in position #{index + 1}'s `blocks` attribute must be an array."
            }
          # If we have an array, continue on to validate blocks.
          elsif content_template['blocks'].present?
            content_template['blocks'].each_with_index do |block_config, b_index|
              validate_block(block_config, index, b_index)
            end
          end

          # Displays must be an array (if set).
          if content_template['displays'].present? && !content_template['displays'].is_a?(Array)
            self.messages << {
              type: :error,
              message: "The content template in position #{index + 1}'s `displays` attribute must be an array."
            }
          # If we have an array, continue on to validate displays.
          elsif content_template['displays'].present?
            if content_template['displays'].any?
              # A folder named after the content template's `var_name` must be
              # present if there are any displays.
              folder_name = content_template['var_name'] || LiveEditor::CLI::naming_for(content_template['title'])[:var_name]

              if folder_name.present? && !File.exist?(templates_folder_loc + '/' + folder_name)
                self.messages << {
                  type: :error,
                  message: "The content template in position #{index + 1} is missing a matching folder at `content_templates/#{folder_name}`."
                }
              end

              # In the following loop, count number of displays counted as default.
              defaults_count = 0

              # Validate each display.
              content_template['displays'].each_with_index do |display_config, d_index|
                validate_display(display_config, index, d_index, content_template, templates_folder_loc)
                defaults_count += 1 if display_config['default'] == true
              end

              if defaults_count > 1
                self.messages << {
                  type: :error,
                  message: "The content template in position #{index + 1} may only have 1 default display."
                }
              end
            end
          end
        end

        # Validates display JSON structure.
        def validate_display(display, content_template_index, display_index, content_template, templates_folder_loc)
          # `title` is required.
          if display['title'].blank?
            self.messages << {
              type: :error,
              message: "The content template in position #{content_template_index + 1}'s display in position #{display_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid `title`."
            }
          end

          # Matching file must be found within subfolder.
          folder_name = content_template['var_name'] || LiveEditor::CLI::naming_for(content_template['title'])[:var_name]
          file_name = display['file_name'] || LiveEditor::CLI::naming_for(display['title'])[:var_name]

          if folder_name.present? && file_name.present?
            file_name += '_display.liquid'

            if !File.exist?(templates_folder_loc + '/' + folder_name + '/' + file_name)
              self.messages << {
                type: :error,
                message: "The content template in position #{content_template_index + 1}'s display in position #{display_index + 1} within the file at `/content_templates/content_templates.json` is missing its matching Liquid template at `/content_templates/#{folder_name}/#{file_name}`."
              }
            end
          end

          # `default` must be a boolean.
          if display['default'].present? && ![true, false].include?(display['default'])
            self.messages << {
              type: :error,
              message: "The content template in position #{content_template_index + 1}'s display in position #{display_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `default`."
            }
          end
        end
      end
    end
  end
end
