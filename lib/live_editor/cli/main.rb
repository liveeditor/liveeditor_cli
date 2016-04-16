require 'thor'
require 'json'
require 'live_editor/api'
require 'live_editor/cli/version'
require 'live_editor/cli/validators/theme_validator'
require 'live_editor/cli/validators/config_validator'
require 'live_editor/cli/validators/config_sample_validator'
require 'live_editor/cli/validators/layouts_validator'
require 'live_editor/cli/validators/content_templates_validator'
require 'live_editor/cli/validators/navigation_validator'
require 'live_editor/cli/validators/assets_validator'
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

      desc 'version', 'Version of Live Editor CLI'
      map %w[-v --version] => :version
      def version
        say "Live Editor CLI v#{LiveEditor::CLI::VERSION}"
      end

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

      desc 'generate SUBCOMMAND', 'Generator for new layouts, content templates, navigation menus, etc.'
      map 'g' => :generate
      def generate(subcommand, title, *blocks)
        # Fail if we're not within a theme folder structure.
        theme_root = LiveEditor::CLI::theme_root_dir! || return

        case subcommand
        when 'content_template'
          generate_content_template(title, blocks, theme_root)
        when 'layout'
          generate_layout(title, theme_root)
        when 'navigation'
          generate_navigation(title, theme_root)
        else
          say 'ERROR: Invalid SUBCOMMAND. Valid options are `layout`, `content_template`, and `navigation`.', :red
          return
        end
      end

      desc 'validate [TARGET]', 'Validate config and assets.'
      def validate(target = nil, options = {})
        # Silent option defaults to false
        options[:silent] = options.has_key?(:silent) ? options[:silent] : false

        # Fail if we're not within a theme folder structure.
        LiveEditor::CLI::theme_root_dir! || return
        target ||= 'all'

        valid = true

        unless options[:silent]
          say ''
          say 'Validating Live Editor theme...'
        end

        # Config validator
        if ['all', 'config'].include?(target)
          unless options[:silent]
            say ''
            say 'Validating config...'
          end

          valid = valid && run_validator([LiveEditor::CLI::Validators::ConfigValidator.new, LiveEditor::CLI::Validators::ConfigSampleValidator.new], options[:silent])
        end

        # Theme validator
        if ['all', 'theme'].include?(target)
          unless options[:silent]
            say ''
            say 'Validating theme...'
          end

          valid = valid && run_validator(LiveEditor::CLI::Validators::ThemeValidator.new, options[:silent])
        end

        # Layouts validator
        if ['all', 'layout', 'layouts'].include?(target)
          unless options[:silent]
            say ''
            say 'Validating layouts...'
          end

          valid = valid && run_validator(LiveEditor::CLI::Validators::LayoutsValidator.new, options[:silent])
        end

        # Content templates validator
        if ['all', 'content_template', 'content_templates'].include?(target)
          unless options[:silent]
            say ''
            say 'Validating content templates...'
          end

          valid = valid && run_validator(LiveEditor::CLI::Validators::ContentTemplatesValidator.new, options[:silent])
        end

        # Navigation validator
        if ['all', 'navigation'].include?(target)
          unless options[:silent]
            say ''
            say 'Validating navigation menus...'
          end

          valid = valid && run_validator(LiveEditor::CLI::Validators::NavigationValidator.new, options[:silent])
        end

        # Assets validator
        if ['all', 'assets'].include?(target)
          unless options[:silent]
            say ''
            say 'Validating assets...'
          end

          valid = valid && run_validator(LiveEditor::CLI::Validators::AssetsValidator.new, options[:silent])
        end

        valid
      end

      desc 'login', 'Log in to the Live Editor service specified in `config.json`.'
      method_option :email, type: :string, desc: 'Email address to use for login'
      method_option :password, type: :string, desc: 'Password to use for login'
      def login
        # Fail if we're not within a theme folder structure.
        theme_root = LiveEditor::CLI::theme_root_dir! || return

        say ''
        say 'Logging in to Live Editor...'

        # Validate config.
        config_validator = LiveEditor::CLI::Validators::ConfigValidator.new
        unless config_validator.valid?
          display_validator_messages(config_validator.errors)
          return
        end

        # Grab config.
        config = LiveEditor::CLI::read_config!
        say "Connecting to #{config['admin_domain']}."
        say ''

        # Ask for email and password from user.
        email = if options[:email].present?
          say "Email: #{options[:email]}"
          options[:email]
        else
          email = ask('Email:')
        end

        password = if options[:password].present?
          say "Password: #{options[:password].gsub(/./, '*')}"
          options[:password]
        else
          ask('Password (typing will be hidden):', echo: false)
        end

        say ''
        say ''

        # Halt if no email or password were provided.
        unless email.present? && password.present?
          display_validator_messages [{
            type: :error,
            message: 'Enter both an email address and password.'
          }]

          return 1
        end

        client = LiveEditor::API::Client.new(domain: config['admin_domain'])
        client.use_ssl = config.has_key?('use_ssl') ? config['use_ssl'] : true
        LiveEditor::API::client = client

        oauth = LiveEditor::API::OAuth.new
        response = oauth.login(email, password)

        if response.success?
          data = response.parsed_body
          LiveEditor::CLI::store_credentials(config['admin_domain'], email, data['access_token'], data['refresh_token'])
          say("You are now logged in to the admin at `#{config['admin_domain']}`.", :green)
        elsif response.errors.any?
          say('ERROR: ' + response.errors.first['detail'], :red)
        end
      end

      desc 'push', 'Deploys theme files and assets to Live Editor service.'
      def push
        # Fail if we're not within a theme folder structure.
        theme_root = LiveEditor::CLI::theme_root_dir! || return

        # Validate the theme. Stop if there are an errors.
        validate('all', silent: true) || return

        LiveEditor::CLI::configure_client!
        client = LiveEditor::API::client

        # Validate login.
        if client.refresh_token.blank?
          say('ERROR: You must be logged in. Run the `liveeditor login` command to login.', :red)
          return
        end

        # Upload assets.
        say 'Uploading assets...'
        files = Dir.glob(theme_root + '/assets/**/*').reject { |file| File.directory?(file) }

        files.each do |file|
          filename = file.sub(theme_root, '').sub('/assets/', '')
          say('/assets/' + filename)

          content_type = LiveEditor::CLI::Uploads::ContentTypeDetector.new(file).detect
          response = nil # Scope this outside of the File.open block below so we can access it aferward.

          File.open(file) do |file_to_upload|
            LiveEditor::CLI::request do
              LiveEditor::API::Themes::Assets::Upload.create(file_to_upload, filename, content_type)
            end
          end
        end
        say ''

        # Upload partials.
        say 'Uploading partials...'
        files = Dir.glob(theme_root + '/partials/**/*').reject { |file| File.directory?(file) }

        files.each do |file|
          filename = file.sub(theme_root, '').sub('/partials/', '')
          say('/partials/' + filename)

          response = nil # Scope this outside of the File.open block below so we can access it aferward.

          File.open(file) do |file_to_upload|
            LiveEditor::CLI::request do
              LiveEditor::API::Themes::Partial.create(filename, file_to_upload.read)
            end
          end
        end
        say ''

        # Upload content templates.
        # templates_folder_loc = theme_root + '/content_templates'
        # templates_config_loc = templates_folder_loc + '/content_templates.json'
        #
        # if File.exist?(templates_folder_loc) && File.exist?(templates_config_loc)
        #   say 'Uploading content templates...'
        #   content_templates_config = File.read(templates_config_loc)
        #   content_templates_config = JSON.parse(content_templates_config)
        #
        #   response = nil # Scope this outside of File.open blocks so we can access it aferward.
        #
        #   content_templates_config['content_templates'].each do |content_template_config|
        #     # Create base content template record via API.
        #     response = LiveEditor::CLI::request do
        #       LiveEditor::API::Themes::ContentTemplate.create content_template_config['title'],
        #         var_name: content_template_config['var_name'],
        #         folder_name: content_template_config['folder_name'],
        #         description: content_template_config['description'],
        #         unique: content_template_config['unique'],
        #         icon_title: content_template_config['icon_title']
        #     end
        #
        #     # Name of folder containing display files.
        #     folder_name = if content_template_config['folder_name'].present?
        #       content_template_config['folder_name']
        #     elsif content_template_config['var_name'].present?
        #       content_template_config['var_name']
        #     else
        #       naming = LiveEditor::CLI::naming_for(content_template_config['title'])
        #       naming[:var_name]
        #     end
        #
        #     content_template_config['displays'].each do |display_config|
        #       # Create display record via API.
        #       response = LiveEditor::CLI::request do
        #         LiveEditor::API::Themes::Display.create display_config['title'],
        #           description: display_config['description'],
        #           file_name: display_config['file_name']
        #       end
        #     end
        #   end
        # end

        # Upload layouts.
        say 'Uploading layouts...'
        layouts_config = File.read(theme_root + '/layouts/layouts.json')
        layouts_config = JSON.parse(layouts_config)

        files = Dir.glob(theme_root + '/layouts/**/*').reject do |file|
          File.directory?(file) || file == theme_root + '/layouts/layouts.json'
        end

        files.each do |file|
          filename = file.sub(theme_root, '').sub('/layouts/', '')
          say('/layouts/' + filename)

          # Grab entry for layout from `layouts.config`.
          config_entry = layouts_config['layouts'].select do |config|
            config['filename'] == filename.sub('_layout.liquid', '') ||
              config['title'].underscore == filename.sub('_layout.liquid', '')
          end.first

          response = nil # Scope this outside of the File.open block below so we can access it aferward.

          File.open(file) do |file_to_upload|
            response = LiveEditor::CLI::request do
              LiveEditor::API::Themes::Layout.create config_entry['title'], filename, file_to_upload.read,
                                                     description: config_entry['description'],
                                                     unique: config_entry['unique']
            end
          end

          # Successful response: process regions
          if response.success?
            # Grab regions from server.
            response_body = response.parsed_body

            server_regions = if response_body.has_key?('included')
              response_body['included'].select { |data| data['type'] == 'regions' }
            else
              []
            end

            # Grab regions from layout config.
            regions_config = config_entry['regions'] || []

            # Loop through regions from server and "fill in the blanks" with matching config.
            server_regions.each do |server_region|
              region_config = regions_config.select do |config|
                config['title'] == server_region['attributes']['title']
              end

              if region_config.any?
                region_config = region_config.first
                region_attrs = {}

                if region_config['var_name'].present? && region_config['var_name'] != server_region['var_name']
                  region_attrs['var_name'] = region_config['var_name']
                end

                if region_config['description'] != server_region['description']
                  region_attrs['description'] = region_config['description']
                end

                if region_config['max_num_content'] != server_region['max_num_content']
                  region_attrs['max_num_content'] = region_config['max_num_content']
                end

                # Only update if there are updates to send.
                unless region_attrs.empty?
                  layout_id = response_body['data']['id']
                  region_id = server_region['id']

                  region_response = LiveEditor::CLI::request do
                    LiveEditor::API::Themes::Region.update(layout_id, region_id, region_attrs)
                  end

                  # Report error and exit if request failed.
                  if region_response.error?
                    region_response.errors.each do |key, value|
                      key = key.underscore
                      say("ERROR: Region `#{key}` `#{region_attrs[key]}` #{value.first}", :red)
                    end

                    return
                  end
                end
              end
            end
          # Error: abort
          else
            # TODO: Report actual errors
            say('ERROR: Unable to process layouts.', :red)
            return
          end
        end

      rescue LiveEditor::API::OAuthRefreshError => e
        say "Your login credentials have expired. Please login again with the `liveeditor login` command", :red
        return
      end

      # Thor should not include anything in this block in its generated help
      # docs.
      no_commands do
        # Displays validator's messages.
        def display_validator_messages(messages)
          messages.each do |message|
            say("#{message[:type].upcase}: #{message[:message]}", message_color_for(message[:type]))
          end
        end

        # Generates content template.
        def generate_content_template(title, blocks, theme_root)
          content_templates_folder = theme_root + '/content_templates'
          Dir.mkdir(content_templates_folder) unless File.exist?(content_templates_folder)

          content_template_config_loc = content_templates_folder + '/content_templates.json'
          title_naming = LiveEditor::CLI::naming_for(title)

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
            block_title_naming = LiveEditor::CLI::naming_for(var_name)

            content_template_config['content_templates'].last[:blocks] << {
              title: block_title_naming[:title],
              description: '',
              type: type,
              var_name: block_title_naming[:var_name]
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

        # Generates a layout of given `title`.
        def generate_layout(title, theme_root)
          layout_config_loc = theme_root + '/layouts/layouts.json'
          title_naming = LiveEditor::CLI::naming_for(title)

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

        # Generates navigation item.
        def generate_navigation(title, theme_root)
          nav_config_loc = theme_root + '/navigation/navigation.json'
          title_naming = LiveEditor::CLI::naming_for(title)

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

        # Returns color symbol to use based on type.
        def message_color_for(type)
          case type
          when :error then :red
          when :warning then :yellow
          end
        end

        # Provides theme title to generator templates in
        # `live_editor/cli-templates`.
        def theme_title
          @title
        end

        # Runs a given validator. Pass a single validator or an array of
        # validators to process in unison.
        def run_validator(validator, silent)
          validators = validator.is_a?(Array) ? validator : [validator]
          messages = []
          errors = []

          validators.each do |validator|
            validator.valid?
            messages.concat(validator.messages) if validator.messages.any?
            errors.concat(validator.errors) if validator.errors.any?
          end

          if messages.any?
            display_validator_messages(messages)
          elsif !silent
            say('OK', :green)
          end

          errors.empty?
        end
      end
    end
  end
end
