require 'thor'
require 'json'

module LiveEditor
  module Cli
    module Generators
      class Navigation < Thor
        # We need this for file copying functionality.
        include Thor::Actions

        # Instructs this CLI to look in the templates folder for template source
        # files.
        def self.source_root
          File.dirname(__FILE__) + '/../templates'
        end

        desc 'navigation TITLE', 'Generate files needed for a new navigation menu'
        def navigation(title)
          # Fail if we're not within a theme folder structure.
          theme_root = LiveEditor::Cli::theme_root_dir! || return

          nav_config_loc = theme_root + '/navigation/navigation.json'
          title_naming = LiveEditor::Cli::naming_for(title)

          say "Creating a new navigation menu titled \"#{title_naming[:title]}\"..."
          say '      append  navigation/navigation.json'

          # If the navigation's config file is already there, append new menu to it.
          if File.exist?(nav_config_loc)
            begin
              nav_config = JSON.parse(File.read(nav_config_loc))
            rescue Exception => e
              say 'The file at navigation/navigation.json does not have valid JSON markup.', :red
              return
            end

            nav_config['navigation'] << {
              title: title_naming[:title],
              var_name: title_naming[:var_name],
              description: ''
            }

            File.open(nav_config_loc, 'w+') do |f|
              f.write(JSON.pretty_generate(nav_config))
              f.write("\n")
            end
          # If we don't yet have a navigation.json file, create it and add the new
          # menu to it.
          else
            new_nav = {
              navigation: [
                {
                  title: title_naming[:title],
                  var_name: title_naming[:var_name],
                  description: ''
                }
              ]
            }

            File.open(nav_config_loc, 'w+') do |f|
              f.write(JSON.pretty_generate(new_nav))
              f.write("\n")
            end
          end

          # Create new Liquid file.
          copy_file('generate/navigation.liquid', "navigation/#{title_naming[:var_name]}_navigation.liquid")
        end
      end
    end
  end
end
