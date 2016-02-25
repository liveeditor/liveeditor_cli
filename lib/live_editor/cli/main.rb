require 'thor'
require 'live_editor/api'
require 'live_editor/cli/version'
require 'live_editor/cli/generators/content_template_generator'
require 'live_editor/cli/generators/layout_generator'
require 'live_editor/cli/generators/navigation_generator'
require 'live_editor/cli/generate'
require 'live_editor/cli/validators/theme_validator'
require 'live_editor/cli/validators/config_validator'
require 'live_editor/cli/validators/config_sample_validator'
require 'live_editor/cli/validators/layouts_validator'
require 'live_editor/cli/validators/content_templates_validator'
require 'live_editor/cli/validators/navigation_validator'
require 'live_editor/cli/validators/assets_validator'
require 'active_support/core_ext/string'

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
      subcommand 'generate', LiveEditor::CLI::Generate

      desc 'validate [TARGET]', 'Validate config and assets.'
      def validate(target = nil)
        # Fail if we're not within a theme folder structure.
        LiveEditor::CLI::theme_root_dir! || return
        target ||= 'all'

        say ''
        say 'Validating Live Editor theme...'

        # Config validator
        if ['all', 'config'].include?(target)
          say ''
          say 'Validating config...'
          run_validator([LiveEditor::CLI::Validators::ConfigValidator.new, LiveEditor::CLI::Validators::ConfigSampleValidator.new])
        end

        # Theme validator
        if ['all', 'theme'].include?(target)
          say ''
          say 'Validating theme...'
          run_validator(LiveEditor::CLI::Validators::ThemeValidator.new)
        end

        # Layouts validator
        if ['all', 'layout', 'layouts'].include?(target)
          say ''
          say 'Validating layouts...'
          run_validator(LiveEditor::CLI::Validators::LayoutsValidator.new)
        end

        # Content templates validator
        if ['all', 'content_template', 'content_templates'].include?(target)
          say ''
          say 'Validating content templates...'
          run_validator(LiveEditor::CLI::Validators::ContentTemplatesValidator.new)
        end

        # Navigation validator
        if ['all', 'navigation'].include?(target)
          say ''
          say 'Validating navigation menus...'
          run_validator(LiveEditor::CLI::Validators::NavigationValidator.new)
        end

        # Assets validator
        if ['all', 'assets'].include?(target)
          say ''
          say 'Validating assets...'
          run_validator(LiveEditor::CLI::Validators::AssetsValidator.new)
        end
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
        config = JSON.parse(File.read(theme_root + '/config.json'))
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

          return
        end

        LiveEditor::API::admin_domain = config['admin_domain']
        LiveEditor::API::use_ssl = config.has_key?('use_ssl') ? config['use_ssl'] : true
        oauth = LiveEditor::API::OAuth.new
        response = oauth.login(email, password)

        if response.is_a?(Hash) && response['refresh_token'].present?
          LiveEditor::CLI::store_credentials(config['admin_domain'], email, response['refresh_token'])
          say("You are now logged in to the admin at `#{config['admin_domain']}`.", :green)
        elsif response.is_a?(Hash) && response['error'].present?
          say('ERROR: ' + response['error'], :red)
        end
      end

      # Thor should not include anything in this block in its generated help docs.
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

        # Provides theme title to generator templates in
        # `live_editor/cli-templates`.
        def theme_title
          @title
        end

        # Runs a given validator. Pass a single validator or an array of
        # validators to process in unison.
        def run_validator(validator)
          validators = validator.is_a?(Array) ? validator : [validator]
          messages = []

          validators.each do |validator|
            validator.valid?
            messages.concat(validator.messages) if validator.messages.any?
          end

          if messages.any?
            display_validator_messages(messages)
          else
            say('OK', :green)
          end
        end
      end
    end
  end
end
