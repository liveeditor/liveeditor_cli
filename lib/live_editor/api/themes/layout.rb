module LiveEditor
  module API
    module Themes
      class Layout
        # Creates a `layout` record.
        #
        # Required arguments:
        #
        # -  `title` - Title of layout.
        # -  `file_name` - Name of layout file. For example: `home.liquid`.
        # -  `content` - Contents of layout.
        #
        # Optional attributes:
        # -  `description` - Description of layout.
        # -  `unique` - Whether or not only one page in the entire site may
        #    reference this layout. (Defaults to `false`.)
        def self.create(title, file_name, content, attributes = {})
          attributes[:unique] ||= false

          LiveEditor::API::client.post('/themes/layouts', payload: {
            data: {
              type: 'layouts',
              attributes: {
                'title' => title,
                'file-name' => file_name,
                'content' => content,
                'description' => attributes[:description],
                'unique' => attributes[:unique]
              }
            }
          })
        end
      end
    end
  end
end
