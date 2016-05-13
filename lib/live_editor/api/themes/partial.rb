module LiveEditor
  module API
    module Themes
      class Partial
        # Creates a `partial` record.
        #
        # Arguments:
        #
        # -  `theme_id` - ID of theme to associate this partial with.
        # -  `file_name` - Name of partial file. For example: `header.liquid` or
        #    `blog/masthead.liquid`.
        # -  `content` - Contents of partial.
        def self.create(theme_id, file_name, content)
          LiveEditor::API::client.post("/themes/#{theme_id}/partials", payload: {
            data: {
              type: 'partials',
              attributes: {
                'file-name' => file_name,
                'content' => content
              }
            }
          })
        end
      end
    end
  end
end
