module LiveEditor
  module CLI
    module Commands
      module New
        def self.included(thor)
          thor.class_eval do
            desc 'new TITLE', 'Create a new skeleton theme'
            def new(title)
              # Fail if we're already within another theme folder structure.
              if LiveEditor::CLI::theme_root_dir
                say 'ERROR: Cannot create a new theme within the folder of another theme.'
                return
              end

              # Figure out values for title, folder name, and path.
              title_naming = LiveEditor::CLI::naming_for(title)
              @title = title_naming[:title]
              say "Creating a new Live Editor theme titled \"#{@title}\"..."

              # Copy source to new theme folder name.
              directory 'new', title_naming[:var_name]
            end

            # Thor will not include anything in this block in its generated help
            # docs.
            no_commands do
              # Provides theme title to generator templates in
              # `live_editor/cli-templates`.
              def theme_title
                @title
              end
            end
          end
        end
      end
    end
  end
end
