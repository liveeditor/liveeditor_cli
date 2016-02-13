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

      # Thor should not include anything in this block in its generated help docs.
      no_commands do
        def theme_title
          @title
        end
      end
    end
  end
end
