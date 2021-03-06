module LiveEditor
  module API
    module Themes
      class Layout
        # Creates a `layout` record.
        #
        # Required arguments:
        #
        # -  `theme_id` - ID of theme to associate this layout with.
        # -  `title` - Title of layout.
        # -  `file_name` - Name of layout file. For example:
        #    `home_layout.liquid`.
        # -  `content` - Contents of layout.
        #
        # Optional attributes:
        #
        # -  `description` - Description of layout.
        # -  `unique` - Whether or not only one page in the entire site may
        #    reference this layout. (Defaults to `false`.)
        def self.create(theme_id, title, file_name, content, attributes = {})
          attributes[:unique] ||= false

          LiveEditor::API::client.post("/themes/#{theme_id}/layouts", payload: {
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
