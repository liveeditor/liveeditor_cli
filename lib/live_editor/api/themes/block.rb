module LiveEditor
  module API
    module Themes
      class Block
        # Creates a `block` record.
        #
        # Required arguments:
        #
        # -  `content_template_id` - ID of content template record to associate
        #    this block with.
        # -  `title` - Title of block as it will be displayed to content authors
        #    in the admin interface.
        # -  `data_type` - Type of data that the block will record. Valid values
        #    are `text`, `image`, `video`, `audio`, `file`, and `link`.
        # -  `position` - Order in which to display this block in the editor.
        #
        # Optional attributes:
        # -  `var_name` - Variable name used to reference this block in display
        #    code and other parts of the theme.
        # -  `description` - Description of block to display on editor
        #    interfaces.
        # -  `required` - Whether or not the field is required. Defaults to
        #    `false`.
        # -  `inline` - If the `type` is set to `text`, passing `true` for this
        #    option specifies that the text is not to be wrapped in any
        #    block-level elements like `<div>` or `<p>` tags. This allows you to
        #    be able to mark up this text within predefined block-level elements
        #    in your display templates, but with the ability for content authors
        #    to still use inline-formatting tags like `<strong>` and `<em>`.
        def self.create(content_template_id, title, data_type, position, attributes = {})
          attributes[:required] ||= false
          attributes[:inline] ||= false

          LiveEditor::API::client.post("/themes/content-templates/#{content_template_id}/blocks", payload: {
            data: {
              type: 'blocks',
              attributes: {
                'title' => title,
                'data-type' => data_type,
                'position' => position,
                'var-name' => attributes[:var_name],
                'description' => attributes[:description],
                'required' => attributes[:required],
                'inline' => attributes[:inline]
              }
            }
          })
        end
      end
    end
  end
end
