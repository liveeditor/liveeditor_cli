require 'live_editor/cli/validators/theme_validator'
require 'live_editor/cli/validators/config_validator'
require 'live_editor/cli/validators/config_sample_validator'
require 'live_editor/cli/validators/layouts_validator'
require 'live_editor/cli/validators/region_validator'
require 'live_editor/cli/validators/content_templates_validator'
require 'live_editor/cli/validators/block_validator'
require 'live_editor/cli/validators/display_validator'
require 'live_editor/cli/validators/navigation_validator'
require 'live_editor/cli/validators/assets_validator'

module LiveEditor
  module CLI
    module Commands
      module Validate
        def self.included(thor)
          thor.class_eval do
            desc 'validate [TARGET]', 'Validate config and assets.'
            def validate(target = nil, options = {})
              # Silent option defaults to false
              options[:silent] = options.has_key?(:silent) ? options[:silent] : false

              # Fail if we're not within a theme folder structure.
              LiveEditor::CLI::theme_root_dir! || return
              target ||= 'all'

              valid = true

              unless options[:silent]
                say ''
                say 'Validating Live Editor theme...'
              end

              # Config validator
              if ['all', 'config'].include?(target)
                unless options[:silent]
                  say ''
                  say 'Validating config...'
                end

                valid = valid && run_validator([LiveEditor::CLI::Validators::ConfigValidator.new, LiveEditor::CLI::Validators::ConfigSampleValidator.new], options[:silent])
              end

              # Theme validator
              if ['all', 'theme'].include?(target)
                unless options[:silent]
                  say ''
                  say 'Validating theme...'
                end

                valid = valid && run_validator(LiveEditor::CLI::Validators::ThemeValidator.new, options[:silent])
              end

              # Content templates validator
              if ['all', 'content_template', 'content_templates'].include?(target)
                unless options[:silent]
                  say ''
                  say 'Validating content templates...'
                end

                valid = valid && run_validator(LiveEditor::CLI::Validators::ContentTemplatesValidator.new, options[:silent])
              end

              # Layouts validator
              if ['all', 'layout', 'layouts'].include?(target)
                unless options[:silent]
                  say ''
                  say 'Validating layouts...'
                end

                valid = valid && run_validator(LiveEditor::CLI::Validators::LayoutsValidator.new, options[:silent])
              end

              # Navigation validator
              if ['all', 'navigation'].include?(target)
                unless options[:silent]
                  say ''
                  say 'Validating navigation menus...'
                end

                valid = valid && run_validator(LiveEditor::CLI::Validators::NavigationValidator.new, options[:silent])
              end

              # Assets validator
              if ['all', 'assets'].include?(target)
                unless options[:silent]
                  say ''
                  say 'Validating assets...'
                end

                valid = valid && run_validator(LiveEditor::CLI::Validators::AssetsValidator.new, options[:silent])
              end

              valid
            end

            # Thor will not include anything in this block in its generated help
            # docs.
            no_commands do
              # Runs a given validator. Pass a single validator or an array of
              # validators to process in unison.
              def run_validator(validator, silent)
                validators = validator.is_a?(Array) ? validator : [validator]
                messages = []
                errors = []

                validators.each do |validator|
                  validator.valid?
                  messages.concat(validator.messages) if validator.messages.any?
                  errors.concat(validator.errors) if validator.errors.any?
                end

                if messages.any?
                  display_validator_messages(messages)
                elsif !silent
                  say('OK', :green)
                end

                errors.empty?
              end
            end
          end
        end
      end
    end
  end
end
