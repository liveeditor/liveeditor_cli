require 'net/http'
require 'net/http/post/multipart'

module LiveEditor
  module API
    module Themes
      module Assets
        class Upload
          # Uploads a file to S3 based on passed in `signature`.
          #
          # Arguments:
          #
          # -  `theme_id` - ID of theme that the upload will be associated with.
          # -  `file` - File object with file to upload read in.
          # -  `file_name` - Name of file, including path from theme's `assets`
          #    folder.
          # -  `content_type` - MIME type to associate with file.
          def self.create(theme_id, file, file_name, content_type)
            signature, response = upload_file_to_s3(theme_id, file, file_name, content_type)
            send_upload_to_live_editor(theme_id, file, file_name, signature)
          end

        private

          # Sends info about upload to Live Editor for further processing.
          def self.send_upload_to_live_editor(theme_id, file, file_name, signature)
            LiveEditor::API::client.post("/themes/#{theme_id}/assets/uploads", payload: {
              data: {
                type: 'asset-uploads',
                attributes: {
                  'file-name' => file_name,
                  'key' => signature['key'],
                  'content-type' => signature['Content-Type'],
                  'file-size' => file.size
                }
              }
            })
          end

          # Uploads file to S3 store and returns signature that was generated.
          def self.upload_file_to_s3(theme_id, file, file_name, content_type)
            response = LiveEditor::API::Themes::Assets::Signature::create(theme_id, file_name, content_type)
            signature = response.parsed_body
            uri = URI.parse(signature['endpoint'])

            request = Net::HTTP::Post::Multipart.new uri.path, key: signature['key'], 'Content-Type' => signature['Content-Type'],
            policy: signature['policy'], 'x-amz-credential' => signature['x-amz-credential'],
            'x-amz-algorithm' => signature['x-amz-algorithm'], 'x-amz-date' => signature['x-amz-date'],
            'x-amz-signature' => signature['x-amz-signature'], acl: signature['acl'],
            file: UploadIO.new(file, signature['Content-Type'], file_name.split('/').last)

            response = Net::HTTP.start(uri.host, use_ssl: LiveEditor::API::client.use_ssl?) do |http|
              http.request(request)
            end

            [signature, LiveEditor::API::Response.new(response)]
          end
        end
      end
    end
  end
end
