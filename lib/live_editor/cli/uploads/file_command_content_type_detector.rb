require 'cocaine'

module LiveEditor
  module CLI
    module Uploads
      class FileCommandContentTypeDetector
        # NOTE: This class is lifted from
        # `Paperclip::FileCommandContentTypeDetector`, last updated from
        # Paperclip commit `523bd46c768226893f23889079a7aa9c73b57d68`.

        SENSIBLE_DEFAULT = "application/octet-stream"

        def initialize(filename)
          @filename = filename
        end

        def detect
          type_from_file_command
        end

      private

        def type_from_file_command
          # On BSDs, `file` doesn't give a result code of 1 if the file doesn't exist.
          type = begin
            Cocaine::CommandLine.new("file", "-b --mime :file").run(file: @filename)
          rescue Cocaine::CommandLineError => e
            puts "Error while determining content type: #{e}"
            SENSIBLE_DEFAULT
          end

          if type.nil? || type.match(/\(.*?\)/)
            type = SENSIBLE_DEFAULT
          end

          type.split(/[:;\s]+/).first
        end
      end
    end
  end
end
