module LiveEditor
  module Cli
    # Returns a hash with 2 values for the `title`:
    #
    # 1. `title` is the titleized version. Ex. 'My Theme'
    # 2. `var_name` is the underscored version. Ex. 'my_theme'
    def self.naming_for(title)
      {
        title: title =~ /_/ ? title.titleize : title,
        var_name: title =~ /_/ ? title : title.underscore.gsub(' ', '_')
      }
    end
  end
end

require_relative 'cli/main'
require_relative 'cli/generate'
