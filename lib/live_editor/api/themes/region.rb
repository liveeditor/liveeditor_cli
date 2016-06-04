module LiveEditor
  module API
    module Themes
      class Region
        # Updates a `region` record.
        #
        # Required arguments:
        #
        # -  `theme_id` - ID of theme that the layout is associated with.
        # -  `layout_id` - ID of layout.
        # -  `id` - ID of region.
        # -  `attributes` - Hash of attributes with new values to update.
        #
        # Optional attributes:
        #
        # -  `title` - Title of region to display in editor interfaces.
        # -  `var_name` - Variable name used to reference the region from
        #    region tags in the layout's markup.
        # -  `description` - Description of region to display in editor
        #    interfaces.
        # -  `max_num_content` - Maximum number of content items allowed within
        #    this region.
        # -  `content_templates` - Array of IDs of content templates to include
        #    in the `content-templates` relationship payload.
        def self.update(theme_id, layout_id, id, attributes = {})
          payload = {
            data: {
              type: 'regions',
              id: id,
              attributes: {}
            }
          }

          attributes.except('content_templates').each do |key, value|
            payload[:data][:attributes][key.to_s.dasherize] = value
          end

          if attributes['content_templates'].present? && attributes['content_templates'].any?
            payload[:data][:relationships] = {}
            payload[:data][:relationships]['content-templates'] = { data: [] }

            attributes['content_templates'].each do |content_template_id|
              payload[:data][:relationships]['content-templates'][:data] << {
                type: 'content-templates',
                id: content_template_id
              }
            end
          end

          LiveEditor::API::client.patch("/themes/#{theme_id}/layouts/#{layout_id}/regions/#{id}", payload: payload)
        end
      end
    end
  end
end
