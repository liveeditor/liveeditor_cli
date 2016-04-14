require 'spec_helper'

RSpec.describe LiveEditor::API::Themes::Layout do
  let(:client) { LiveEditor::API::Client.new(domain: 'example.liveeditorapp.com', access_token: '1234567890', refresh_token: '0987654321') }
  before { LiveEditor::API::client = client }

  describe '.create' do
    context 'with valid input' do
      let(:content) do
        content = <<-CONTENT
          <!DOCTYPE html>
          <html>
          <body>
          {% region 'main' %}
          </body>
          </html>
        CONTENT

        content.strip
      end

      let(:response) do
        subject.class.create 'Home', 'home_layout.liquid', content, description: 'A description.',
                             unique: true
      end

      let(:request_payload) do
        {
          data: {
            type: 'layouts',
            attributes: {
              'title' => 'Home',
              'file-name' => 'home_layout.liquid',
              'content' => content,
              'description' => 'A description.',
              'unique' => true
            }
          }
        }
      end

      let(:response_payload) do
        {
          'data' => {
            'type' => 'layouts',
            'id' => '1234',
            'attributes' => {
              'title' => 'Home',
              'file-name' => 'home_layout.liquid',
              'content' => content,
              'description' => 'A description.',
              'unique' => true
            },
            'relationships' => {
              'type' => 'regions',
              'id' => '1235'
            }
          },
          'included' => [
            {
              'data' => {
                'type' => 'regions',
                'id' => '1235',
                'attributes' => {
                  'title' => 'Main',
                  'var-name' => 'main'
                }
              }
            }
          ]
        }
      end

      before do
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/layouts')
          .with(body: request_payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 201, headers: { 'Content-Type' => 'application/vnd.api+json'}, body: response_payload.to_json)
      end

      it 'is successful' do
        expect(response.success?).to eql true
      end

      it 'returns HTTP Created response' do
        expect(response.response).to be_a Net::HTTPCreated
      end

      it 'returns the expected response payload' do
        expect(response.parsed_body).to eql response_payload
      end
    end # with valid input

    context 'with invalid input' do
      let(:content) do
        content = <<-CONTENT
          <!DOCTYPE html>
          <html>
          <body>
          {% region 'main' %}
          </body>
          </html>
        CONTENT

        content.strip
      end

      let(:response) { subject.class.create 'Home', '', content, description: 'A description.', unique: true }

      let(:request_payload) do
        {
          data: {
            type: 'layouts',
            attributes: {
              'title' => 'Home',
              'file-name' => '',
              'content' => content,
              'description' => 'A description.',
              'unique' => true
            }
          }
        }
      end

      let(:response_payload) do
        {
          'errors' => [
            {
              'source' => {
                'pointer' => '/data/attributes/file-name'
              },
              'detail' => "can't be blank"
            }
          ]
        }
      end

      before do
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/layouts')
          .with(body: request_payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 422, headers: { 'Content-Type' => 'application/vnd.api+json'}, body: response_payload.to_json)
      end

      it 'is error' do
        expect(response.error?).to eql true
      end

      it 'returns HTTP Unprocessable Entity response' do
        expect(response.response).to be_a Net::HTTPUnprocessableEntity
      end

      it 'returns the expected response payload' do
        expect(response.errors).to eql({
          'file-name' => ["can't be blank"]
        })
      end
    end # with invalid input
  end # .update
end
