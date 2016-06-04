module LiveEditor
  module API
    module Themes
      class Navigation
        # Creates a `navigation` record.
        #
        # Required arguments:
        #
        # -  `theme_id` - ID of theme to associate this navigation menu with.
        # -  `title` - Title of layout.
        # -  `file_name` - Name of navigation file containing Liquid markup.
        #    For example, `global_navigation.liquid`.
        # -  `content` - Liquid markup containing contents and logic of
        #    navigation menu.
        #
        # Optional attributes:
        #
        # -  `var_name` - This will be used to reference this navigation menu
        #    within a navigation tag in a layout or content template display. If
        #    not provided, `var_name` defaults to the value of `title`, all
        #    lowercase and underscored (e.g., if the `title` is "Executive
        #    Team," the default value to use within the code would be
        #    `executive_team`).
        # -  `description` - Description of navigation menu.
        def self.create(theme_id, title, file_name, content, attributes = {})
          LiveEditor::API::client.post("/themes/#{theme_id}/navigations", payload: {
            data: {
              type: 'navigations',
              attributes: {
                'title' => title,
                'file-name' => file_name,
                'content' => content,
                'description' => attributes[:description],
                'var-name' => attributes[:var_name]
              }
            }
          })
        end
      end
    end
  end
end
