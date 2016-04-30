require 'live_editor/cli/validators/validator'

module LiveEditor
  module CLI
    module Validators
      class DisplayValidator < Validator
        # Attributes
        attr_reader :config, :content_template_index, :display_index, :content_template_config, :templates_folder_loc

        # Constructor.
        def initialize(config, content_template_index, display_index, content_template_config, templates_folder_loc)
          super()
          @config = config
          @content_template_index = content_template_index
          @display_index = display_index
          @content_template_config = content_template_config
          @templates_folder_loc = templates_folder_loc
        end

        # Returns whether or not any errors were found within this display.
        #
        # An array of errors and notices will also be stored in the `messages`
        # attribute after running this method.
        def valid?
          # `title` is required.
          if self.config['title'].blank?
            self.messages << {
              type: :error,
              message: "The content template in position #{content_template_index + 1}'s display in position #{display_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid `title`."
            }
          end

          # Matching file must be found within subfolder.
          folder_name = self.content_template_config['folder_name'] || self.content_template_config['var_name'] || LiveEditor::CLI::naming_for(self.content_template_config['title'])[:var_name]
          file_name = self.config['file_name'] || LiveEditor::CLI::naming_for(self.config['title'])[:var_name]

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
          if self.config['default'].present? && ![true, false].include?(self.config['default'])
            self.messages << {
              type: :error,
              message: "The content template in position #{content_template_index + 1}'s display in position #{display_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `default`."
            }
          end

          self.errors.size == 0
        end
      end
    end
  end
end
