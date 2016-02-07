require 'thor'
require 'json'

module LiveEditor
  module Cli
    class Generate < Thor
      # We need this for file copying functionality.
      include Thor::Actions

      # Instructs this CLI to look in the templates folder for template source
      # files.
      def self.source_root
        File.dirname(__FILE__) + '/templates'
      end

      desc 'content_template', 'Generator for new content templates.'
      subcommand 'content_template', LiveEditor::Cli::Generators::ContentTemplate

      desc 'layout', 'Generator for new layouts.'
      subcommand 'layout', LiveEditor::Cli::Generators::Layout

      desc 'layout', 'Generator for new navigation menus.'
      subcommand 'layout', LiveEditor::Cli::Generators::Navigation
    end
  end
end
