require 'thor'
require 'json'

module LiveEditor
  module Cli
    module Generators
      class LayoutGenerator < Thor
        # We need this for file copying functionality.
        include Thor::Actions

        # Instructs this CLI to look in the templates folder for template source
        # files.
        def self.source_root
          File.dirname(__FILE__) + '/../templates'
        end

        desc 'layout TITLE', 'Generate files needed for a new layout'
        def layout(title)
          # Fail if we're not within a theme folder structure.
          theme_root = LiveEditor::Cli::theme_root_dir! || return

          layout_config_loc = theme_root + '/layouts/layouts.json'
          title_naming = LiveEditor::Cli::naming_for(title)

          say "Creating a new Live Editor layout titled \"#{title_naming[:title]}\"..."
          say '      append  layouts/layouts.json'

          # If the layout's config file is already there, append new layout to it.
          if File.exist?(layout_config_loc)
            begin
              layout_config = JSON.parse(File.read(layout_config_loc))
            rescue Exception => e
              say 'The file at layouts/layout.json does not have valid JSON markup.', :red
              return
            end

            layout_config['layouts'] << {
              title: title_naming[:title]
            }

            File.open(layout_config_loc, 'w+') do |f|
              f.write(JSON.pretty_generate(layout_config))
              f.write("\n")
            end
          # If we don't yet have a layouts.json file, create it and add the new
          # layout to it.
          else
            new_layout = {
              layouts: [
                {
                  title: title_naming[:title]
                }
              ]
            }

            File.open(layout_config_loc, 'w+') do |f|
              f.write(JSON.pretty_generate(new_layout))
              f.write("\n")
            end
          end

          # Create new Liquid file.
          copy_file('generate/layout.liquid', "layouts/#{title_naming[:var_name]}_layout.liquid")
        end
      end
    end
  end
end
