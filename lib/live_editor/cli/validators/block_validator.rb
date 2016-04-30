require 'live_editor/cli/validators/validator'

module LiveEditor
  module CLI
    module Validators
      class BlockValidator < Validator
        # Attributes
        attr_reader :config, :content_template_index, :block_index

        # Constructor.
        def initialize(config, content_template_index, block_index)
          super()
          @config = config
          @content_template_index = content_template_index
          @block_index = block_index
        end

        # Returns whether or not any errors were found within this block.
        #
        # An array of errors and notices will also be stored in the `messages`
        # attribute after running this method.
        def valid?
          # Title is required.
          if self.config['title'].blank?
            self.messages << {
              type: :error,
              message: "The content template in position #{self.content_template_index + 1}'s block in position #{self.block_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid `title`."
            }
          end

          # Data type is required.
          if self.config['data_type'].blank?
            self.messages << {
              type: :error,
              message: "The content template in position #{self.content_template_index + 1}'s block in position #{self.block_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid `data_type`."
            }
          end

          # Required is optional but must be boolean if set.
          if self.config['required'].present? && ![true, false].include?(self.config['required'])
            self.messages << {
              type: :error,
              message: "The content template in position #{self.content_template_index + 1}'s block in position #{self.block_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `required`."
            }
          end

          # `inline` is optional but must be boolean if set.
          if self.config['inline'].present? && ![true, false].include?(self.config['inline'])
            self.messages << {
              type: :error,
              message: "The content template in position #{self.content_template_index + 1}'s block in position #{self.block_index + 1} within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `inline`."
            }
          end

          self.errors.size == 0
        end
      end
    end
  end
end
