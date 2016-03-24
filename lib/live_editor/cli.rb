require 'netrc'
require 'live_editor/api/client'
require 'live_editor/cli/uploads/content_type_detector'
require 'live_editor/cli/main'

module LiveEditor
  module CLI
    def self.configure_client!
      config = read_config!
      n = Netrc.read
      email, password = n[config['admin_domain']]

      if email.present? && password.present?
        admin_domain_parts = config['admin_domain'].split(':')
        port = admin_domain_parts.last if admin_domain_parts.size == 2
        use_ssl = !config.has_key?('use_ssl') || config['use_ssl']

        password_parts = password.split('|')
        access_token = password_parts.first
        refresh_token = password_parts.last

        LiveEditor::API::client = LiveEditor::API::Client.new domain: config['admin_domain'], port: port, access_token: access_token,
                                                              refresh_token: refresh_token, use_ssl: use_ssl
      else
        LiveEditor::API::client = LiveEditor::API::Client.new
      end
    end

    # Stores login and password for a given admin domain.
    def self.store_credentials(admin_domain, email, access_token, refresh_token)
      n = Netrc.read
      password = [access_token, refresh_token].join('|')
      n[admin_domain] = email, password
      n.save
    end

    # Returns a hash with 2 values for the `title`:
    #
    # 1. `title` is the titleized version. Ex. 'My Theme'
    # 2. `var_name` is the underscored version. Ex. 'my_theme'
    def self.naming_for(title)
      {
        title: title =~ /[A-Z]/ ? title : title.titleize,
        var_name: title =~ /_/ ? title : title.underscore.gsub(' ', '_')
      }
    end

    # Reads config file. Assumes that it has already been validated, so be
    # sure to do that before running this method.
    def self.read_config!
      theme_root = LiveEditor::CLI::theme_root_dir!
      JSON.parse(File.read(theme_root + '/config.json'))
    end

    # Returns path to root folder for this theme. This allows the user to run
    # commands from any subfolder within the theme.
    #
    # If the script is being run from outside of any theme, this returns `nil`.
    def self.theme_root_dir
      current_dir = Dir.pwd

      loop do
        if Dir[current_dir + '/theme.json'].size > 0
          break
        else
          dir_array = current_dir.split('/')
          popped = dir_array.pop
          break if popped.nil?

          current_dir = dir_array.join('/')
        end
      end

      current_dir.size > 0 ? current_dir : nil
    end

    # Displays an error message and returns `false` if a process is not being
    # run within a theme's directory (or any subdirectories of the theme).
    # Otherwise, returns `true`.
    def self.theme_root_dir!
      theme_root = theme_root_dir
      puts("ERROR: Must be within an existing Live Editor theme's folder to run this command.") unless theme_root
      theme_root
    end
  end
end
