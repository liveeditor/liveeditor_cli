module LiveEditor
  module CLI
    module Config
      class NavigationConfig < Config
        # Returns array of navigation menus stored in `config.`
        def navigation
          self.parsed? ? self.config['navigation'] : []
        end
      end
    end
  end
end
