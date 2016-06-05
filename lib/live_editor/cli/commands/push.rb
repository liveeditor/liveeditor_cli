module LiveEditor
  module CLI
    module Commands
      module Push
        def self.included(thor)
          thor.class_eval do
            desc 'push', 'Deploys theme files and assets to Live Editor service.'
            def push
              # Fail if we're not within a theme folder structure.
              theme_root = LiveEditor::CLI::theme_root_dir! || return

              # Validate the theme.
              validate('all', silent: true) || return

              # Validate login.
              validate_login || return

              # Get site data to see if it has a live theme to compare against.
              success, site = load_site
              return unless success

              # If there is a current live theme, grab it.
              success, current_theme = load_theme(site)
              return unless success

              # Create theme version to reference in following requests.
              success, new_theme = create_new_theme
              return unless success

              # Upload assets.
              upload_assets(theme_root, current_theme, new_theme) || return

              # Upload partials.
              upload_partials(theme_root, new_theme) || return

              # Upload navigation menus.
              upload_navigation(theme_root, new_theme) || return

              # Upload content templates.
              success, content_templates = upload_content_templates(theme_root, new_theme)
              return unless success

              # Upload layouts.
              upload_layouts(theme_root, new_theme, content_templates) || return

              # Make new theme live
              publish_theme(new_theme)

            rescue LiveEditor::API::OAuthRefreshError => e
              say 'Your login credentials have expired. Please login again with the `liveeditor login` command', :red
              return
            end

            # Thor will not include anything in this block in its generated help
            # docs.
            no_commands do
              # Creates new theme.
              #
              # Returns 2 values:
              #
              # 1.  `true` or `false` depending on whether or not the creation
              #     was successful.
              # 2.  The parsed body of the API request, representing the newly-
              #     created theme record.
              def create_new_theme
                say 'Creating theme...'
                response = LiveEditor::CLI::request { LiveEditor::API::Theme.create }

                if response.error?
                  LiveEditor::CLI::display_server_errors_for(response)
                  return false, nil
                end

                say ''
                return true, response.parsed_body
              end

              # Returns whether or not a given file is already uploaded to the current
              # theme based on name and fingerprint.
              def find_theme_asset(existing_theme_assets, file, current_theme, options = {})
                return nil unless current_theme['included'].present?

                # Grab asset IDs hooked up to theme asset records.
                asset_ids = existing_theme_assets.map { |theme_asset| theme_asset['relationships']['asset']['data']['id'] }

                # Grab asset records.
                existing_assets = current_theme['included'].select do |inc|
                  inc['type'] == 'assets' && asset_ids.include?(inc['id'])
                end

                # If found, compare its fingerprint.
                if existing_assets.count > 0
                  fingerprint = Digest::MD5.hexdigest(file.read)

                  asset = existing_assets.select do |existing_asset|
                    # Find sub-asset
                    sub_asset = current_theme['included'].select do |asset|
                      asset['type'].start_with?('asset-') &&
                        asset['id'] == existing_asset['relationships']['asset']['data']['id']
                    end

                    fingerprint == sub_asset.first['attributes']['fingerprint']
                  end

                  asset.any? ? asset.first : nil
                # If not found, return `nil`.
                else
                  nil
                end
              end

              # Loads current site based on user's login.
              def load_site
                response = LiveEditor::CLI::request { LiveEditor::API::Site::current }

                if response.success?
                  return true, response.parsed_body
                else
                  LiveEditor::CLI::display_server_errors_for(response)
                  return false, nil
                end
              end

              # Loads theme for site if a relationship was returned along with its response.
              def load_theme(site)
                if site['data']['relationships']['theme']['data'].present?
                  response = LiveEditor::CLI::request do
                    LiveEditor::API::Theme::find site['data']['relationships']['theme']['data']['id'],
                                                 include: %w(theme-assets theme-assets.asset theme-assets.asset.asset partials navigations layouts layouts.regions content-templates content-templates.blocks content-templates.displays)
                  end

                  if response.success?
                    return true, response.parsed_body
                  else
                    LiveEditor::CLI::display_server_errors_for(response)
                    return false, nil
                  end
                else
                  return true, nil
                end
              end

              def publish_theme(new_theme)
                say 'Publishing theme...'

                response = LiveEditor::CLI::request do
                  LiveEditor::API::Site.update(theme_id: new_theme['data']['id'])
                end

                if response.success?
                  say 'Published!'
                  say ''
                  true
                else
                  LiveEditor::CLI::display_server_errors_for(response)
                  false
                end
              end

              # Uploads new assets to server and associates existing ones with new theme. Returns `true` if
              # successful, false if not.
              def upload_assets(theme_root, current_theme, new_theme)
                files = Dir.glob(theme_root + '/assets/**/*').reject { |file| File.directory?(file) }

                if files.any?
                  say 'Uploading assets...'

                  files.each do |file|
                    file_name = file.sub(theme_root, '').sub('/assets/', '')
                    response = nil # Scope this outside of the `File.open` block below so we can access it afterward.

                    File.open(file) do |file_to_upload|
                      # Determine whether or not this asset is already uploaded to the
                      # server.
                      if current_theme.present?
                        existing_theme_assets = current_theme['included'].select do |inc|
                          inc['type'] == 'theme-assets' && inc['attributes']['path'] == file_name
                        end

                        matched_asset = find_theme_asset(existing_theme_assets, file_to_upload, current_theme)
                      end

                      # If a matching asset was found, skip uploading it and add
                      # existing asset record to new theme.
                      if matched_asset.present?
                        say("/assets/#{file_name} - already uploaded, skipping")

                        # Associate the matched asset with the new theme.
                        response = LiveEditor::CLI::request do
                          LiveEditor::API::Themes::Asset.create(new_theme['data']['id'], matched_asset['id'], file_name)
                        end
                      # If no match was found, upload the file.
                      else
                        say("/assets/#{file_name} - uploading")
                        content_type = LiveEditor::CLI::Uploads::ContentTypeDetector.new(file).detect

                        # This call will automatically associate the new asset with the new theme.
                        response = LiveEditor::CLI::request do
                          LiveEditor::API::Themes::Assets::Upload.create new_theme['data']['id'], file_to_upload,
                                                                         file_name, content_type
                        end
                      end
                    end

                    if response.present? && response.error?
                      say('ERROR', :red)
                      LiveEditor::CLI::display_server_errors_for(response)
                      return false
                    end
                  end

                  say ''
                end

                true
              end

              # Uploads content templates to the server. Returns `true` if
              # successful, `false` if not.
              def upload_content_templates(theme_root, new_theme)
                content_templates_config = LiveEditor::CLI::content_templates_config

                # We're going to store content template `id`s/`var_name`s so we
                # can use them later in regions.
                content_templates = {}

                if content_templates_config.parsed?
                  say 'Uploading content templates...'

                  content_templates_config.content_templates.each do |content_template_config|
                    say content_template_config['title']

                    # Create base content template record via API.
                    response = LiveEditor::CLI::request do
                      LiveEditor::API::Themes::ContentTemplate.create(
                        new_theme['data']['id'],
                        content_template_config['title'],
                        var_name: content_template_config['var_name'],
                        folder_name: content_template_config['folder_name'],
                        description: content_template_config['description'],
                        unique: content_template_config['unique'],
                        icon_title: content_template_config['icon_title']
                      )
                    end

                    if response.error?
                      LiveEditor::CLI::display_server_errors_for(response)
                      return false, content_templates
                    end

                    content_template_id = response.parsed_body['data']['id']
                    content_templates[response.parsed_body['data']['attributes']['var-name']] = {
                      'id' => content_template_id
                    }

                    # Blocks
                    if content_template_config['blocks'].present?
                      content_template_config['blocks'].each_with_index do |block_config, index|
                        block_response = LiveEditor::CLI::request do
                          LiveEditor::API::Themes::Block.create(
                            new_theme['data']['id'],
                            content_template_id,
                            block_config['title'],
                            block_config['data_type'],
                            index,
                            var_name: block_config['var_name'],
                            description: block_config['description'],
                            required: block_config['required'],
                            inline: block_config['inline']
                          )
                        end

                        if block_response.error?
                          LiveEditor::CLI::display_server_errors_for block_response,
                                                                     prefix: "Block in position #{index + 1}:"
                          return false, content_templates
                        end
                      end
                    end

                    # Displays
                    # Name of folder containing display files.
                    folder_name = if content_template_config['folder_name'].present?
                      content_template_config['folder_name']
                    elsif content_template_config['var_name'].present?
                      content_template_config['var_name']
                    else
                      naming = LiveEditor::CLI::naming_for(content_template_config['title'])
                      naming[:var_name]
                    end

                    if content_template_config['displays'].present?
                      content_template_config['displays'].each_with_index do |display_config, index|
                        file_name = if display_config['file_name'].present?
                          display_config['file_name']
                        else
                          LiveEditor::CLI::naming_for(display_config['title'])[:var_name] + '_display.liquid'
                        end

                        file = "#{theme_root}/content_templates/#{folder_name}/#{file_name}"
                        say "/content_templates/#{folder_name}/#{file_name}"

                        # Create display record via API.
                        File.open(file) do |file_to_upload|
                          display_response = LiveEditor::CLI::request do
                            LiveEditor::API::Themes::Display.create(
                              new_theme['data']['id'],
                              content_template_id,
                              display_config['title'],
                              file_to_upload.read,
                              index,
                              description: display_config['description'],
                              file_name: display_config['file_name']
                            )
                          end

                          if display_response.error?
                            LiveEditor::CLI::display_server_errors_for display_response,
                                                                       prefix: "Display in position #{index + 1}:"
                            return false, content_templates
                          end
                        end
                      end
                    end
                  end

                  say ''
                end

                return true, content_templates
              end

              # Uploads layouts to server. Returns `true` if successful, `false`
              # if not.
              def upload_layouts(theme_root, new_theme, content_templates)
                layouts_config = LiveEditor::CLI::layouts_config

                files = Dir.glob(theme_root + '/layouts/**/*').reject do |file|
                  File.directory?(file) || file == "#{theme_root}/layouts/layouts.json"
                end

                if files.any?
                  say 'Uploading layouts...'

                  files.each_with_index do |file, index|
                    file_name = file.sub(theme_root, '').sub('/layouts/', '')
                    say('/layouts/' + file_name)

                    # Grab entry for layout from `layouts.config`.
                    config_entry = layouts_config.layouts.select do |config|
                      config['file_name'] == file_name.sub('_layout.liquid', '') ||
                        config['title'].underscore == file_name.sub('_layout.liquid', '')
                    end.first

                    response = nil # Scope this outside of the File.open block below so we can access it aferward.

                    File.open(file) do |file_to_upload|
                      response = LiveEditor::CLI::request do
                        LiveEditor::API::Themes::Layout.create new_theme['data']['id'], config_entry['title'],
                                                               file_name, file_to_upload.read,
                                                               description: config_entry['description'],
                                                               unique: config_entry['unique']
                      end
                    end

                    if response.error?
                      LiveEditor::CLI::display_server_errors_for(response, prefix: "Layout in position #{index + 1}:")
                      return false
                    end

                    # Process regions
                    response_body = response.parsed_body

                    server_regions = if response_body.has_key?('included')
                      response_body['included'].select { |data| data['type'] == 'regions' }
                    else
                      []
                    end

                    # Grab regions from layout config.
                    regions_config = config_entry['regions'] || []

                    # Loop through regions from server and "fill in the blanks"
                    # with matching config.
                    server_regions.each do |server_region|
                      region_config = regions_config.select do |config|
                        var_name = config['var_name'] || LiveEditor::CLI::naming_for(config['title'])[:var_name]
                        var_name == server_region['attributes']['var-name']
                      end

                      if region_config.any?
                        region_config = region_config.first
                        region_attrs = {}

                        if region_config['title'].present? && region_config['title'] != server_region['title']
                          region_attrs['title'] = region_config['title']
                        end

                        if region_config['description'] != server_region['description']
                          region_attrs['description'] = if region_config['description'].present?
                            region_config['description']
                          else
                            nil
                          end
                        end

                        if region_config['max_num_content'] != server_region['max_num_content']
                          region_attrs['max_num_content'] = region_config['max_num_content']
                        end

                        if region_config['content_templates'].present? && region_config['content_templates'].any?
                          content_template_ids = []

                          region_config['content_templates'].each do |var_name|
                            content_template_ids << content_templates[var_name]['id']
                          end

                          region_attrs['content_templates'] = content_template_ids
                        end

                        # Only update if there are updates to send.
                        unless region_attrs.empty?
                          layout_id = response_body['data']['id']
                          region_id = server_region['id']

                          response = LiveEditor::CLI::request do
                            LiveEditor::API::Themes::Region.update new_theme['data']['id'], layout_id, region_id,
                                                                   region_attrs
                          end

                          if response.error?
                            LiveEditor::CLI::display_server_errors_for response,
                                                                       prefix: "Region `#{server_region['attributes']['title']}`:"
                            return false
                          end
                        end
                      end
                    end
                  end

                  say ''
                end

                true
              end

              # Uploads navigation menus to the server. Returns `true` if
              # successful, `false` if not.
              def upload_navigation(theme_root, new_theme)
                navigation_config = LiveEditor::CLI::navigation_config

                if navigation_config.parsed?
                  say 'Uploading navigation menus...'

                  navigation_config.navigation.each do |nav_config|
                    say nav_config['title']

                    file_name = nav_config['file_name'] || nav_config['var_name'] || LiveEditor::CLI::naming_for(nav_config['title'])[:var_name]
                    file_name = "#{file_name}_navigation.liquid" unless file_name.end_with?('_navigation.liquid')
                    content = File.read(theme_root + '/navigation/' + file_name)

                    # Create navigation record via API.
                    response = LiveEditor::CLI::request do
                      LiveEditor::API::Themes::Navigation.create new_theme['data']['id'], nav_config['title'], file_name,
                                                                 content, description: nav_config['description'],
                                                                 var_name: nav_config['var_name']
                    end

                    if response.error?
                      LiveEditor::CLI::display_server_errors_for(response)
                      return false
                    end
                  end

                  say ''
                end

                true
              end

              # Uploads partials to the server. Returns `true` if successful,
              # `false` if not.
              def upload_partials(theme_root, new_theme)
                files = Dir.glob(theme_root + '/partials/**/*').reject { |file| File.directory?(file) }

                if files.any?
                  say 'Uploading partials...'

                  files.each do |file|
                    file_name = file.sub(theme_root, '').sub('/partials/', '')
                    say('/partials/' + file_name)

                    # Scope this outside of the File.open block below so we can
                    # access it aferward.
                    response = nil

                    File.open(file) do |file_to_upload|
                      response = LiveEditor::CLI::request do
                        LiveEditor::API::Themes::Partial.create(new_theme['data']['id'], file_name, file_to_upload.read)
                      end
                    end

                    if response.error?
                      LiveEditor::CLI::display_server_errors_for(response)
                      return false
                    end
                  end

                  say ''
                end

                true
              end

              # Validates that user is logged in. Instructs them to login if
              # not. Returns `true` if user is logged in, `false` if not.
              def validate_login
                LiveEditor::CLI::configure_client!

                if LiveEditor::API::client.refresh_token.present?
                  true
                else
                  say('ERROR: You must be logged in. Run the `liveeditor login` command to login.', :red)
                  false
                end
              end
            end
          end
        end
      end
    end
  end
end
