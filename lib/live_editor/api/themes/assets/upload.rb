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
          # -  `file` - File object.
          def self.create(file, filename, content_type)
            signature, response = upload_file_to_s3(file, filename, content_type)
            send_upload_to_live_editor(file, filename, signature)
          end

        private

          # Sends info about upload to Live Editor for further processing.
          def self.send_upload_to_live_editor(file, filename, signature)
            LiveEditor::API::client.post('/themes/assets/uploads', payload: {
              data: {
                type: 'asset-uploads',
                attributes: {
                  'file-name' => filename,
                  'key' => signature['key'],
                  'content-type' => signature['Content-Type'],
                  'file-size' => file.size
                }
              }
            })
          end

          # Uploads file to S3 store and returns signature that was generated.
          def self.upload_file_to_s3(file, filename, content_type)
            response = LiveEditor::API::Themes::Assets::Signature::create(filename, content_type)
            signature = response.parsed_body
            uri = URI.parse(signature['endpoint'])

            request = Net::HTTP::Post::Multipart.new uri.path, key: signature['key'], 'Content-Type' => signature['Content-Type'],
            policy: signature['policy'], 'x-amz-credential' => signature['x-amz-credential'],
            'x-amz-algorithm' => signature['x-amz-algorithm'], 'x-amz-date' => signature['x-amz-date'],
            'x-amz-signature' => signature['x-amz-signature'], acl: signature['acl'],
            file: UploadIO.new(file, signature['Content-Type'], filename.split('/').last)

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
