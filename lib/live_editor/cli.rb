module LiveEditor
  module Cli
    # Returns a hash with 2 values for the `title`:
    #
    # 1. `title` is the titleized version. Ex. 'My Theme'
    # 2. `var_name` is the underscored version. Ex. 'my_theme'
    def self.naming_for(title)
      {
        title: title =~ /[A-Z]/ ? title : title.titleize,
        var_name: title =~ /_/ ? title : title.underscore.gsub(' ', '_')
      }
    end

    # Returns path to root folder for this theme. This allows the user to run
    # commands from any subfolder within the theme.
    #
    # If the script is being run from outside of any theme, this returns `nil`.
    def self.theme_root_dir
      current_dir = FileUtils.pwd

      loop do
        if Dir[current_dir + '/theme.json'].size > 0
          break
        else
          dir_array = current_dir.split('/')
          popped = dir_array.pop
          break if popped.nil?

          current_dir = dir_array.join('/')
        end
      end

      current_dir.size > 0 ? current_dir : nil
    end
  end
end

require_relative 'cli/main'
require_relative 'cli/generate'
