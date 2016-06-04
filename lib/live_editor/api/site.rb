module LiveEditor
  module API
    class Site
      # Returns record representing the current site.
      #
      # Options:
      #
      # -  `include` - Name of relationship to include with the request. Pass an
      #    array to include multiple.
      def self.current(options = {})
        query_string = LiveEditor::API::include_query_string_for(options[:include])
        query_string = '?' + query_string if query_string.present?
        LiveEditor::API::client.get("/site#{query_string}")
      end

      # Updates record representing the current site.
      #
      # Optional attributes:
      #
      # -  `title` - Updated title of site.
      # -  `subdomain_slug` - Updated subdomain slug for site.
      # -  `theme_id` - Updated published theme version for site.
      def self.update(attributes = {})
        payload = {
          data: {
            type: 'sites',
            attributes: {}
          }
        }

        attributes.except(:theme_id).each do |key, value|
          payload[:data][:attributes][key.to_s.dasherize] = value
        end

        if attributes[:theme_id].present?
          payload[:data][:relationships] = {}
          payload[:data][:relationships]['theme'] = {
            data: {
              type: 'themes',
              id: attributes[:theme_id]
            }
          }
        end

        LiveEditor::API::client.patch('/site', payload: payload)
      end
    end
  end
end
