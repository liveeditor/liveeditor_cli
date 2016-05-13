module LiveEditor
  module API
    class Theme
      # Creates a `theme` record.
      def self.create
        LiveEditor::API::client.post('/themes', payload: {
          data: {
            type: 'themes',
            attributes: {}
          }
        })
      end
    end
  end
end
