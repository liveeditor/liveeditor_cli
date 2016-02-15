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
      subcommand 'content_template', LiveEditor::Cli::Generators::ContentTemplateGenerator

      desc 'layout', 'Generator for new layouts.'
      subcommand 'layout', LiveEditor::Cli::Generators::LayoutGenerator

      desc 'navigation', 'Generator for new navigation menus.'
      subcommand 'navigation', LiveEditor::Cli::Generators::NavigationGenerator
    end
  end
end
