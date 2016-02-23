require 'uri'
require 'live_editor/api/version'
require 'live_editor/api/oauth'

module LiveEditor
  module API
    # Default user agent to use for API calls.
    USER_AGENT = "liveeditor_api gem/#{LiveEditor::API::VERSION} (#{RUBY_PLATFORM}) ruby/#{RUBY_VERSION}"

    # Returns configured admin domain for API calls.
    def self.admin_domain
      @@admin_domain
    end

    # Configures admin domain to use for API calls.
    def self.admin_domain=(admin_domain)
      @@admin_domain = admin_domain
    end

    # Returns URI object configured with `admin_domain`, `use_ssel?` and
    # provided parameters.
    def self.uri(path)
      protocol = use_ssl? ? 'https' : 'http'
      domain = admin_domain.split('.')
      domain = domain.insert(1, 'api')
      domain = domain.join('.')
      URI("#{protocol}://#{domain}#{path}")
    end

    # Returns port to use use for API calls.
    def self.port
      @@port
    end

    # Configures port to use for API calls.
    def self.port=(port)
      @@port = port
    end

    # Returns whether or not to use SSL for API calls.
    def self.use_ssl?
      @@use_ssl
    end

    # Configures whether or not to use SSL for API calls.
    def self.use_ssl=(use_ssl)
      @@use_ssl = use_ssl
    end

    # Returns configuration for user agent.
    def self.user_agent
      @@user_agent ||= USER_AGENT
    end

    # Configures user agent to use for API calls.
    def self.user_agent=(agent)
      @@user_agent = agent
    end
  end
end
