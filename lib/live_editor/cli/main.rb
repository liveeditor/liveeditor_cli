require 'thor'

module LiveEditor
  module Cli
    class Main < Thor
      desc 'version', 'Version of Live Editor CLI'
      def version
        require 'live_editor/cli/version'
        say "Live Editor CLI v#{LiveEditor::Cli::VERSION}"
      end
    end
  end
end
