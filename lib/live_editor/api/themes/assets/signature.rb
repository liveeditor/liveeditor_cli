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
          # -  `theme_id` - ID of theme that the asset upload will be associated
          #    with.
          # -  `filename` - Path from theme's `assets/`` folder and filename to
          #    be uploaded.
          # -  `content_type` - MIME type of asset file that will be uploaded.
          def self.create(theme_id, filename, content_type)
            LiveEditor::API::client.post("/themes/#{theme_id}/assets/signatures", form_data: {
              filename: filename,
              'content-type' => content_type
            })
          end
        end
      end
    end
  end
end
