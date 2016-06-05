require 'spec_helper'

RSpec.describe LiveEditor::API::Themes::Asset do
  let(:client) do
    LiveEditor::API::Client.new domain: 'example.liveeditorapp.com', access_token: '1234567890',
                                refresh_token: '0987654321'
  end

  let(:theme_id)       { SecureRandom.uuid }
  let(:asset_id)       { SecureRandom.uuid }
  let(:theme_asset_id) { SecureRandom.uuid}

  before { LiveEditor::API::client = client }

  describe '.create' do
    context 'with valid input' do
      let(:response) do
        LiveEditor::API::Themes::Asset.create(theme_id, asset_id, 'images/logo.png')
      end

      let(:request_payload) do
        {
          data: {
            type: 'theme-assets',
            attributes: {
              path: 'images/logo.png'
            },
            relationships: {
              asset: {
                data: {
                  type: 'assets',
                  id: asset_id
                }
              }
            }
          }
        }
      end

      let(:response_payload) do
        {
          'data' => {
            'type' => 'theme-assets',
            'id' => theme_asset_id,
            'attributes' => {
              'path' => 'images/logo.png'
            },
            'relationships' => {
              'theme' => {
                'data' => {
                  'type' => 'themes',
                  'id' => theme_id
                }
              },
              'asset' => {
                'data' => {
                  'type' => 'assets',
                  'id' => asset_id
                }
              }
            }
          }
        }
      end

      before do
        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/assets")
          .with(body: request_payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 201, headers: { 'Content-Type' => 'application/vnd.api+json'},
                     body: response_payload.to_json)
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
      let(:response) do
        LiveEditor::API::Themes::Asset.create(theme_id, asset_id, '')
      end

      let(:request_payload) do
        {
          data: {
            type: 'theme-assets',
            attributes: { path: '' },
            relationships: {
              asset: {
                data: {
                  type: 'assets',
                  id: asset_id
                }
              }
            }
          }
        }
      end

      let(:response_payload) do
        {
          'errors' => [
            {
              'source' => {
                'pointer' => '/data/attributes/path'
              },
              'detail' => "can't be blank"
            }
          ]
        }
      end

      before do
        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/assets")
          .with(body: request_payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 422, headers: { 'Content-Type' => 'application/vnd.api+json'},
                     body: response_payload.to_json)
      end

      it 'is error' do
        expect(response.error?).to eql true
      end

      it 'returns HTTP Unprocessable Entity response' do
        expect(response.response).to be_a Net::HTTPUnprocessableEntity
      end

      it 'returns the expected response payload' do
        expect(response.errors).to eql({
          'path' => ["can't be blank"]
        })
      end
    end # with invalid input
  end # .update
end
