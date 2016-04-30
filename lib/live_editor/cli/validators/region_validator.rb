require 'live_editor/cli/validators/validator'

module LiveEditor
  module CLI
    module Validators
      class RegionValidator < Validator
        # Attributes
        attr_reader :config, :layout_index, :region_index, :content_templates_config

        # Constructor.
        def initialize(config, layout_index, region_index, content_templates_config)
          super()
          @config = config
          @layout_index = layout_index
          @region_index = region_index
          @content_templates_config = content_templates_config
        end

        # Returns whether or not any errors were found within this region.
        #
        # An array of errors and notices will also be stored in the `messages`
        # attribute after running this method.
        def valid?
          # Title is required.
          if self.config['title'].blank?
            self.messages << {
              type: :error,
              message: "The layout in position #{self.layout_index + 1}'s region in position #{self.region_index + 1} must have a `title`."
            }
          end

          if self.config['content_templates'].present?
            # Content templates must be an array.
            if !self.config['content_templates'].is_a?(Array)
              self.messages << {
                type: :error,
                message: "The layout in position #{self.layout_index + 1}'s region in position #{self.region_index + 1} has an invalid `content_templates` attribute: must be an array."
              }
            # Content templates must be real content templates
            else
              self.config['content_templates'].each do |content_template_var_name|
                # Check if it's a base content type.
                if LiveEditor::API::Themes::BASE_CONTENT_TEMPLATE_VAR_NAMES.include?(content_template_var_name)
                  matching_template_found = true
                # Otherwise, search custom types.
                else
                  matching_templates = self.content_templates_config.content_templates.select do |matching_template|
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
                    message: "The layout in position #{self.layout_index + 1}'s region in position #{self.region_index + 1} has an invalid `content_template`: `#{content_template_var_name}`."
                  }
                end
              end
            end
          end

          # Max num content must be an integer (if present).
          if self.config['max_num_content'].present? && !self.config['max_num_content'].is_a?(Integer)
            self.messages << {
              type: :error,
              message: "The layout in position #{self.layout_index + 1}'s region in position #{self.region_index + 1} has an invalid `max_num_content` attribute: must be an integer."
            }
          end

          self.errors.size == 0
        end
      end
    end
  end
end
