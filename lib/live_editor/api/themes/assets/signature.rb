require 'net/http'

module LiveEditor
  module API
    module Themes
      module Assets
        class Signature
          ##
          # Provides signature and headers required for uploading a new theme
          # asset to Live Editor's S3 file store.
          #
          # Arguments:
          #
          # -  `filename` - Path from theme's `assets/`` folder and filename to
          #    be uploaded.
          def self.create(filename, content_type)
            client = LiveEditor::API::client
            client.post('/themes/assets/signatures', form_data: { filename: filename, 'content-type' => content_type })
          end
        end
      end
    end
  end
end
