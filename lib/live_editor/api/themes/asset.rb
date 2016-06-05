module LiveEditor
  module API
    module Themes
      class Asset
        # Creates a `theme_asset` record.
        #
        # Required arguments:
        #
        # -  `theme_id` - ID of theme that the asset is to be associated with.
        # -  `asset_id` - ID of asset record to associate with the theme.
        # -  `path` - Name of file, including path from theme's `assets`
        #    folder.
        def self.create(theme_id, asset_id, path)
          LiveEditor::API::client.post("/themes/#{theme_id}/assets", payload: {
            data: {
              type: 'theme-assets',
              attributes: {
                'path' => path
              },
              relationships: {
                asset: {
                  data: {
                    type: 'assets',
                    id: asset_id
                  }
                }
              }
            }
          })
        end
      end
    end
  end
end
