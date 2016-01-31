require 'thor'
require 'live_editor/cli/version'
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

      desc 'new NAME', 'Create a new skeleton theme'
      def new(name)
        # Figure out values for title, folder name, and path.
        @title = title_for_name(name)
        @folder_name = path_for_name(name)
        say "Creating a new Live Editor theme titled \"#{@title}\"..."

        # Copy source to new theme folder name.
        directory 'new', @folder_name
      end

      # Thor should not include anything in this block in its generated help docs.
      no_commands do
        def theme_title
          @title
        end
      end

    private

      # Creates a path for a theme with a given name.
      #
      # Examples:
      # my_theme -> my_theme
      # My Theme -> my_theme
      def path_for_name(name)
        name =~ /_/ ? name : name.underscore.gsub(' ', '_')
      end

      # Creates a title for a theme with a given name.
      #
      # Examples:
      # my_theme -> My Theme
      # My Theme -> My Theme
      def title_for_name(name)
        name =~ /_/ ? name.titleize : name
      end
    end
  end
end
