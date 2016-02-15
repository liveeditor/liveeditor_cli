require 'thor'
require 'json'

module LiveEditor
  module Cli
    module Generators
      class ContentTemplateGenerator < Thor
        # We need this for file copying functionality.
        include Thor::Actions

        # Instructs this CLI to look in the templates folder for template source
        # files.
        def self.source_root
          File.dirname(__FILE__) + '/../templates'
        end

        desc 'content_template TITLE [BLOCKS]', 'Generate files needed for a new content template'
        def content_template(title, *blocks)
          # Fail if we're not within a theme folder structure.
          theme_root = LiveEditor::Cli::theme_root_dir! || return

          content_templates_folder = theme_root + '/content_templates'
          Dir.mkdir(content_templates_folder) unless File.exist?(content_templates_folder)

          content_template_config_loc = content_templates_folder + '/content_templates.json'
          title_naming = LiveEditor::Cli::naming_for(title)

          say "Creating a new content template titled \"#{title_naming[:title]}\"..."
          say '      append  content_templates/content_templates.json'

          # If the content templates config file is already there, append a new
          # content template to it.
          if File.exist?(content_template_config_loc)
            begin
              content_template_config = JSON.parse(File.read(content_template_config_loc))
            rescue Exception => e
              say 'The file at content_templates/content_templates.json does not contain valid JSON markup.',
                  :red
              return
            end

            content_template_config['content_templates'] << {
              title: title_naming[:title],
              description: '',
              var_name: title_naming[:var_name],
              blocks: [],
              displays: [
                {
                  title: 'Default',
                  description: ''
                }
              ]
            }

            File.open(content_template_config_loc, 'w+') do |f|
              f.write(JSON.pretty_generate(content_template_config))
              f.write("\n")
            end
          # If we don't yet have a content_templates.json file, create it and add
          # the new content template to it.
          else
            content_template_config = {
              'content_templates' => [
                title: title_naming[:title],
                description: '',
                var_name: title_naming[:var_name],
                blocks: [],
                displays: [
                  {
                    title: 'Default',
                    description: ''
                  }
                ]
              ]
            }
          end

          # If there are any blocks defined, add them to the config.
          blocks.each do |block|
            values = block.split(':')
            var_name = values.first
            type = values.size == 2 ? values.last : 'text'
            title_naming = LiveEditor::Cli::naming_for(var_name)

            content_template_config['content_templates'].last[:blocks] << {
              title: title_naming[:title],
              description: '',
              type: type,
              var_name: title_naming[:var_name]
            }
          end

          # Write the new content_templates.json file to disk.
          File.open(content_template_config_loc, 'w+') do |f|
            f.write(JSON.pretty_generate(content_template_config))
            f.write("\n")
          end

          # Create new subfolder.
          Dir.mkdir(Dir.pwd + '/content_templates') unless File.exist?(Dir.pwd + '/content_templates')
          Dir.mkdir(Dir.pwd + '/content_templates/' + title_naming[:var_name]) unless File.exist?(Dir.pwd + '/content_templates/' + title_naming[:var_name])
          copy_file('generate/display.liquid', "content_templates/#{title_naming[:var_name]}/default_display.liquid")
        end
      end
    end
  end
end
