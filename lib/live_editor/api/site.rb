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
    end
  end
end
