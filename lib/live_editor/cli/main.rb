require 'thor'
require 'live_editor/cli/version'
require 'live_editor/cli/generators'
require 'live_editor/cli/generate'
require 'live_editor/cli/validators/theme_validator'
require 'live_editor/cli/validators/config_validator'
require 'live_editor/cli/validators/config_sample_validator'
require 'live_editor/cli/validators/layouts_validator'
require 'live_editor/cli/validators/content_templates_validator'
require 'live_editor/cli/validators/navigation_validator'
require 'live_editor/cli/validators/assets_validator'
require 'active_support/core_ext/string'

module LiveEditor
  module Cli
    class Main < Thor
      include Thor::Actions

      check_unknown_options!

      # Instructs this CLI to return a positive number on failure.
      def self.exit_on_failure?
        true
      end

      # Instructs this CLI to look in the templates folder for template source
      # files.
      def self.source_root
        File.dirname(__FILE__) + '/templates'
      end

      desc 'version', 'Version of Live Editor CLI'
      map %w[-v --version] => :version
      def version
        say "Live Editor CLI v#{LiveEditor::Cli::VERSION}"
      end

      desc 'new TITLE', 'Create a new skeleton theme'
      def new(title)
        # Fail if we're already within another theme folder structure.
        if LiveEditor::Cli::theme_root_dir
          say 'ERROR: Cannot create a new theme within the folder of another theme.'
          return
        end

        # Figure out values for title, folder name, and path.
        title_naming = LiveEditor::Cli::naming_for(title)
        @title = title_naming[:title]
        say "Creating a new Live Editor theme titled \"#{@title}\"..."

        # Copy source to new theme folder name.
        directory 'new', title_naming[:var_name]
      end

      desc 'generate SUBCOMMAND', 'Generator for new layouts, content templates, navigation menus, etc.'
      map 'g' => :generate
      subcommand 'generate', LiveEditor::Cli::Generate

      desc 'validate [TARGET]', 'Validate config and assets.'
      def validate(target = nil)
        # Fail if we're not within a theme folder structure.
        theme_root = LiveEditor::Cli::theme_root_dir! || return
        target ||= 'all'

        say ''
        say 'Validating Live Editor theme...'

        # Config validator
        if ['all', 'config'].include?(target)
          say ''
          say 'Validating config...'
          run_validator([LiveEditor::Cli::Validators::ConfigValidator.new, LiveEditor::Cli::Validators::ConfigSampleValidator.new])
        end

        # Theme validator
        if ['all', 'theme'].include?(target)
          say ''
          say 'Validating theme...'
          run_validator(LiveEditor::Cli::Validators::ThemeValidator.new)
        end

        # Layouts validator
        if ['all', 'layout', 'layouts'].include?(target)
          say ''
          say 'Validating layouts...'
          run_validator(LiveEditor::Cli::Validators::LayoutsValidator.new)
        end

        # Content templates validator
        if ['all', 'content_template', 'content_templates'].include?(target)
          say ''
          say 'Validating content templates...'
          run_validator(LiveEditor::Cli::Validators::ContentTemplatesValidator.new)
        end

        # Navigation validator
        if ['all', 'navigation'].include?(target)
          say ''
          say 'Validating navigation menus...'
          run_validator(LiveEditor::Cli::Validators::NavigationValidator.new)
        end

        # Assets validator
        if ['all', 'assets'].include?(target)
          say ''
          say 'Validating assets...'
          run_validator(LiveEditor::Cli::Validators::AssetsValidator.new)
        end
      end

      # Thor should not include anything in this block in its generated help docs.
      no_commands do
        # Returns color symbol to use based on type.
        def message_color_for(type)
          case type
          when :error then :red
          when :warning then :yellow
          end
        end

        # Provides theme title to generator templates in
        # `live_editor/cli-templates`.
        def theme_title
          @title
        end

        # Runs a given validator. Pass a single validator or an array of
        # validators to process in unison.
        def run_validator(validator)
          validators = validator.is_a?(Array) ? validator : [validator]
          messages = []

          validators.each do |validator|
            validator.valid?
            messages.concat(validator.errors) if validator.errors.any?
          end

          if messages.any?
            messages.each do |message|
              say("#{message[:type].upcase}: #{message[:message]}", message_color_for(message[:type]))
            end
          else
            say('OK', :green)
          end
        end
      end
    end
  end
end
