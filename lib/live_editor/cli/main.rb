require 'thor'
require 'json'
require 'live_editor/api'
require 'live_editor/cli/config'
require 'live_editor/cli/commands'
require 'active_support/core_ext/string'
require 'active_support/rescuable'

module LiveEditor
  module CLI
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

      # Include individual commands.
      include LiveEditor::CLI::Commands::Version
      include LiveEditor::CLI::Commands::New
      include LiveEditor::CLI::Commands::Generate
      include LiveEditor::CLI::Commands::Validate
      include LiveEditor::CLI::Commands::Login
      include LiveEditor::CLI::Commands::Push

      # Thor should not include anything in this block in its generated help
      # docs.
      no_commands do
        # Displays validator's messages.
        def display_validator_messages(messages)
          messages.each do |message|
            say("#{message[:type].upcase}: #{message[:message]}", message_color_for(message[:type]))
          end
        end

        # Returns color symbol to use based on type.
        def message_color_for(type)
          case type
          when :error then :red
          when :warning then :yellow
          end
        end
      end
    end
  end
end
