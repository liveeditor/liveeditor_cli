module LiveEditor
  module CLI
    module Config
      class Config
        # Attributes
        attr_accessor :parsed, :config
        alias_method :parsed?, :parsed

        # Constructor. Reads in and parses a given JSON config file. If
        # everything runs successfully, the `parsed?` attribute should return
        # `true`.
        #
        # Arguments:
        # -  `file_path` - Path of file to read in.
        def initialize(file_path)
          config = File.read(file_path)
          @config = JSON.parse(config)
          @parsed = true
        rescue Exception => e
          @parsed = false
        end
      end
    end
  end
end
