require 'live_editor/api/response'
require 'live_editor/api/oauth'
require 'live_editor/api/site'
require 'live_editor/api/theme'
require 'live_editor/api/themes'
require 'live_editor/api/themes/asset'
require 'live_editor/api/themes/assets/signature'
require 'live_editor/api/themes/assets/upload'
require 'live_editor/api/themes/partial'
require 'live_editor/api/themes/layout'
require 'live_editor/api/themes/region'
require 'live_editor/api/themes/content_template'
require 'live_editor/api/themes/block'
require 'live_editor/api/themes/display'
require 'live_editor/api/themes/navigation'

module LiveEditor
  module API
    # Sets client to use for calls to API.
    #
    # Arguments:
    #
    # -  `client` - Client to use for calls to API. Typically, you'll pass a
    #    configured instance of `liveEditor::API::Client` as this argument.
    def self.client=(client)
      @@client = client
    end

    # Returns client to use for calls to API.
    def self.client
      @@client
    end

    # Returns query string for single or array of string relationship includes.
    def self.include_query_string_for(include)
      if include.present?
        includes = include.is_a?(Array) ? include : [include]
        "include=#{includes.join(',')}"
      else
        ''
      end
    end
  end
end
