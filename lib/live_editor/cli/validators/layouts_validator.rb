module LiveEditor
  module Cli
    module Validators
      class LayoutsValidator
        # Attributes
        attr_reader :errors

        # Constructor.
        def initialize
          @errors = []
        end

        # Returns whether or not any errors were found within
        # `/layouts/layouts.json`.
        #
        # An array of errors and notices will also be stored in the `errors`
        # attribute after running this method.
        def valid?
          # Grab location of /layouts folder.
          layouts_folder_loc = LiveEditor::Cli::theme_root_dir + '/layouts'

          unless File.exist?(layouts_folder_loc)
            self.errors << {
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
              self.errors << {
                type: :error,
                message: 'The file at `/layouts/layouts.json` does not contain valid JSON markup.'
              }

              return false
            end

            # Validate presence of root `layouts` attribute.
            unless layouts_config['layouts'] && layouts_config['layouts'].is_a?(Array)
              self.errors << {
                type: :error,
                message: 'The file at `/layouts/layouts.json` must contain a root `layouts` attribute containing an array.'
              }

              return false
            end

            # Validate each layout's attributes.
            layouts_config['layouts'].each_with_index do |layout_config, index|
              # Title is required.
              if layout_config['title'].blank?
                self.errors << {
                  type: :error,
                  message: "The layout in position #{index + 1} within the file at `/layouts/layouts.json` does not have a valid title."
                }
              end

              # Unique is optional but must be boolean.
              if layout_config['unique'].present? && ![true, false].include?(layout_config['unique'])
                self.errors << {
                  type: :error,
                  message: "The layout in position #{index + 1} within the file at `/layouts/layouts.json` does not have a valid value for `unique`."
                }
              end

              # Filename must have matching liquid file.
              if layout_config['title'].present? || layout_config['filename'].present?
                filename = layout_config['filename'] ? layout_config['filename'] : LiveEditor::Cli::naming_for(layout_config['title'])[:var_name]
                filename += '_layout.liquid'

                unless File.exist?(layouts_folder_loc + '/' + filename)
                  self.errors << {
                    type: :error,
                    message: "The layout in position #{index + 1} is missing its matching Liquid template: `#{filename}`."
                  }
                end
              end

              # Regions must be an array (if set).
              if layout_config['regions'] && !layout_config['regions'].is_a?(Array)
                self.errors << {
                  type: :error,
                  message: "The layout in position #{index + 1}'s `regions` attribute must be an array."
                }

              # If we have an array, continue on to validate regions.
              elsif layout_config['regions']
                layout_config['regions'].each_with_index do |region_config, r_index|
                  # Title is required.
                  if region_config['title'].blank?
                    self.errors << {
                      type: :error,
                      message: "The layout in position #{index + 1}'s region in position #{r_index + 1} must have a `title`."
                    }
                  end

                  # Content templates must be an array (if present).
                  if region_config['content_templates'].present? && !region_config['content_templates'].is_a?(Array)
                    self.errors << {
                      type: :error,
                      message: "The layout in position #{index + 1}'s region in position #{r_index + 1} has an invalid `content_templates` attribute: must be an array."
                    }
                  end

                  # Max num content must be an integer (if present).
                  if region_config['max_num_content'].present? && !region_config['max_num_content'].is_a?(Integer)
                    self.errors << {
                      type: :error,
                      message: "The layout in position #{index + 1}'s region in position #{r_index + 1} has an invalid `max_num_content` attribute: must be an integer."
                    }
                  end
                end
              end
            end
          # No layouts.json.
          else
            self.errors << {
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
