module LiveEditor
  module API
    module Themes
      class ContentTemplate
        # Creates a `content_template` record.
        #
        # Required arguments:
        #
        # -  `theme_id` - ID of theme to associate this content template with.
        # -  `title` - Title of content template.
        #
        # Optional attributes:
        # -  `var_name` - Variable name used to reference this content template
        #    in other parts of the theme.
        # -  `folder_name` - Name of content template display file. For example:
        #    `full_article_display.liquid`.
        # -  `description` - Description of content template to display on
        #    editor interfaces.
        # -  `unique` - Whether or not this content template can only be used
        #    once per page. (Defaults to `false`.)
        # -  `icon_title` - Title of icon to use to represent the content
        #     template.
        def self.create(theme_id, title, attributes = {})
          attributes[:unique] ||= false

          LiveEditor::API::client.post("/themes/#{theme_id}/content-templates", payload: {
            data: {
              type: 'content-templates',
              attributes: {
                'title' => title,
                'var-name' => attributes[:var_name],
                'folder-name' => attributes[:folder_name],
                'description' => attributes[:description],
                'unique' => attributes[:unique],
                'icon-title' => attributes[:icon_title]
              }
            }
          })
        end
      end
    end
  end
end
