module LiveEditor
  module CLI
    module Config
      class LayoutsConfig < Config
        # Returns array of layouts stored in `config.`
        def layouts
          self.parsed? ? self.config['layouts'] : []
        end
      end
    end
  end
end
