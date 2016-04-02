require 'live_editor/api/response'
require 'live_editor/api/oauth'
require 'live_editor/api/themes/assets/signature'
require 'live_editor/api/themes/assets/upload'
require 'live_editor/api/themes/partial'

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
  end
end
