module LiveEditor
  module API
    module Themes
      class Display
        # Creates a `display` record.
        #
        # Required arguments:
        #
        # -  `theme_id` - ID of theme that the content template is associated
        #    with.
        # -  `content_template_id` - ID of content template record to associate
        #    this block with.
        # -  `title` - Title of block as it will be displayed to content authors
        #    in the admin interface.
        # -  `content` - Contents of display containing Liquid markup.
        # -  `position` - Order in which to display this display in the editor.
        #
        # Optional attributes:
        #
        # -  `description` - Description of display to display on editor
        #    interfaces.
        # -  `default_display` - Whether or not this display is the default
        #    display for content based on this content template.
        # -  `file_name` - Name of display file within the theme's content
        #    template folder.
        def self.create(theme_id, content_template_id, title, content, position, attributes = {})
          LiveEditor::API::client.post("/themes/#{theme_id}/content-templates/#{content_template_id}/displays", payload: {
            data: {
              type: 'blocks',
              attributes: {
                'title' => title,
                'content' => content,
                'position' => position,
                'description' => attributes[:description],
                'default-display' => attributes[:default_display],
                'file-name' => attributes[:file_name]
              }
            }
          })
        end
      end
    end
  end
end
