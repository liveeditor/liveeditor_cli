module LiveEditor
  module API
    class Theme
      # Returns a theme record by ID.
      #
      # Options:
      #
      # -  `include` - Name of relationship to include with the request. Pass an
      #    array to include multiple.
      def self.find(id, options = {})
        query_string = LiveEditor::API::include_query_string_for(options[:include])
        query_string = '?' + query_string if query_string.present?
        LiveEditor::API::client.get("/themes/#{id}#{query_string}")
      end

      # Creates a `theme` record.
      #
      # Optional attributes:
      #
      # -  `asset_ids` - Array of asset IDs to associate with the them.
      def self.create(attributes = {})
        payload = {
          data: {
            type: 'themes',
            attributes: {}
          }
        }

        payload = add_assets_to_payload(payload, attributes[:asset_ids])

        LiveEditor::API::client.post('/themes', payload: payload)
      end

      # Updates a `theme` record.
      #
      # Arguments:
      #
      # -  `theme_id` - ID of theme to update.
      #
      # Optional attributes:
      #
      # -  `asset_ids` - Array of asset IDs to associate with the them.
      def self.update(theme_id, attributes = {})
        payload = {
          data: {
            type: 'themes',
            id: theme_id,
            attributes: {}
          }
        }

        payload = add_assets_to_payload(payload, attributes[:asset_ids])

        LiveEditor::API::client.patch("/themes/#{theme_id}", payload: payload)
      end

    private

      # Adds `assets` relationship with associated records.
      #
      # Note: Passing `nil` for `asset_ids` instructs this method to not add the
      # relationship to the payload; passing an empty array instructs this
      # method to add an empty array to the payload and thus clear all assets
      # from the theme.
      def self.add_assets_to_payload(payload, asset_ids)
        # Add in asset IDs via `assets` relationship if they're provided.
        if asset_ids.is_a?(Array)
          payload[:data][:relationships] = {}
          payload[:data][:relationships][:assets] = {}
          payload[:data][:relationships][:assets][:data] = []

          asset_ids.each do |asset_id|
            payload[:data][:relationships][:assets][:data] << {
              type: 'assets',
              id: asset_id
            }
          end
        end

        payload
      end
    end
  end
end
