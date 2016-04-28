module LiveEditor
  module CLI
    module Config
      class ContentTemplatesConfig < Config
        # Returns array of content templates stored in `config.`
        def content_templates
          self.parsed? ? self.config['content_templates'] : []
        end
      end
    end
  end
end
