require 'live_editor/cli/version'

module LiveEditor
  module CLI
    module Commands
      module Version
        def self.included(thor)
          thor.class_eval do
            desc 'version', 'Version of Live Editor CLI'
            map %w[-v --version] => :version
            def version
              say "Live Editor CLI v#{LiveEditor::CLI::VERSION}"
            end
          end
        end
      end
    end
  end
end
