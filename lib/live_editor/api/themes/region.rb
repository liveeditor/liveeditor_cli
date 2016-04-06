module LiveEditor
  module API
    module Themes
      class Region
        # Updates a `region` record.
        #
        # Required arguments:
        #
        # -  `layout_id` - ID of layout.
        # -  `id` - ID of region.
        # -  `attributes` - Hash of attributes with new values to update.
        #
        # Attributes:
        # -  `title` - Title of region to display in editor interfaces.
        # -  `var_name` - Variable name used to reference the region from
        #    region tags in the layout's markup.
        # -  `description` - Description of region to display in editor
        #    interfaces.
        # -  `max_num_content` - Maximum number of content items allowed within
        #    this region.
        def self.update(layout_id, id, attributes = {})
          payload = {
            data: {
              type: 'regions',
              id: id.to_s,
              attributes: {}
            }
          }

          attributes.each do |key, value|
            payload[:data][:attributes][key.to_s.dasherize] = value
          end

          LiveEditor::API::client.patch("/themes/layouts/#{layout_id}/regions/#{id}", payload: payload)
        end
      end
    end
  end
end
