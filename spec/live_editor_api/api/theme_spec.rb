require 'spec_helper'

RSpec.describe LiveEditor::API::Themes::Region do
  let(:client) do
    LiveEditor::API::Client.new domain: 'example.liveeditorapp.com', access_token: '1234567890',
                                refresh_token: '0987654321'
  end

  let(:theme_id) { SecureRandom.uuid }
  let(:asset_id) { SecureRandom.uuid }
  let(:user_id) { SecureRandom.uuid }

  before { LiveEditor::API::client = client }

  describe '.find' do
    context 'with no includes' do
      let(:payload) do
        {
          'data' => {
            'type' => 'themes',
            'id' => theme_id,
            'attributes' => {},
            'relationships' => {
              'user' => {
                'data' => {
                  'type' => 'users',
                  'id' => user_id
                }
              }
            }
          }
        }
      end

      let(:response) do
        LiveEditor::API::Theme.find(theme_id)
      end

      before do
        stub_request(:get, "http://example.api.liveeditorapp.com/themes/#{theme_id}")
          .with(headers: { 'Accept'=>'application/vnd.api+json', 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 200, headers: { 'Content-Type' => 'application/vnd.api+json'}, body: payload.to_json)
      end

      it 'is successful' do
        expect(response.success?).to eql true
      end

      it 'returns HTTP OK response' do
        expect(response.response).to be_a Net::HTTPOK
      end

      it 'returns the expected response payload' do
        expect(response.parsed_body).to eql payload
      end
    end # with no includes

    context 'with included user' do
      let(:payload) do
        {
          'data' => {
            'type' => 'themes',
            'id' => theme_id,
            'attributes' => {},
            'relationships' => {
              'user' => {
                'data' => {
                  'type' => 'users',
                  'id' => user_id
                }
              }
            }
          },
          'included' => [
            {
              'data' => {
                'type' => 'users',
                'id' => user_id
              }
            }
          ]
        }
      end

      let(:response) do
        LiveEditor::API::Theme.find(theme_id, include: 'user')
      end

      before do
        stub_request(:get, "http://example.api.liveeditorapp.com/themes/#{theme_id}?include=user")
          .with(headers: { 'Accept'=>'application/vnd.api+json', 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 200, headers: { 'Content-Type' => 'application/vnd.api+json'}, body: payload.to_json)
      end

      it 'is successful' do
        expect(response.success?).to eql true
      end

      it 'returns HTTP OK response' do
        expect(response.response).to be_a Net::HTTPOK
      end

      it 'returns the expected response payload' do
        expect(response.parsed_body).to eql payload
      end
    end
  end # .find

  describe '.create' do
    context 'with valid input' do
      let(:request_payload) do
        {
          'data' => {
            'type' => 'themes',
            'attributes' => {}
          }
        }
      end

      let(:response_payload) do
        {
          'data' => {
            'type' => 'themes',
            'id' => theme_id,
            'attributes' => {}
          }
        }
      end

      let(:response) do
        LiveEditor::API::Theme.create
      end

      before do
        stub_request(:post, "http://example.api.liveeditorapp.com/themes")
          .with(body: request_payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 200, headers: { 'Content-Type' => 'application/vnd.api+json'},
                     body: response_payload.to_json)
      end

      it 'is successful' do
        expect(response.success?).to eql true
      end

      it 'returns HTTP OK response' do
        expect(response.response).to be_a Net::HTTPOK
      end

      it 'returns the expected response payload' do
        expect(response.parsed_body).to eql response_payload
      end
    end # with valid input

    context 'with valid input and asset IDs' do
      let(:request_payload) do
        {
          'data' => {
            'type' => 'themes',
            'attributes' => {},
            'relationships' => {
              'assets' => {
                'data' => [
                  {
                    'type' => 'assets',
                    'id' => asset_id
                  }
                ]
              }
            }
          }
        }
      end

      let(:response_payload) do
        {
          'data' => {
            'type' => 'themes',
            'id' => theme_id,
            'attributes' => {},
            'relationships' => {
              'assets' => {
                'data' => [
                  {
                    'type' => 'assets',
                    'id' => asset_id
                  }
                ]
              }
            }
          }
        }
      end

      let(:response) do
        LiveEditor::API::Theme.create(asset_ids: [asset_id])
      end

      before do
        stub_request(:post, "http://example.api.liveeditorapp.com/themes")
          .with(body: request_payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 200, headers: { 'Content-Type' => 'application/vnd.api+json'},
                     body: response_payload.to_json)
      end

      it 'is successful' do
        expect(response.success?).to eql true
      end

      it 'returns HTTP OK response' do
        expect(response.response).to be_a Net::HTTPOK
      end

      it 'returns the expected response payload' do
        expect(response.parsed_body).to eql response_payload
      end
    end # with valid input and asset IDs
  end # .create

  describe '.update' do
    let(:payload) do
      {
        'data' => {
          'type' => 'themes',
          'id' => theme_id,
          'attributes' => {},
          'relationships' => {
            'assets' => {
              'data' => [
                {
                  'type' => 'assets',
                  'id' => asset_id
                }
              ]
            }
          }
        }
      }
    end

    context 'with valid input' do
      let(:response) do
        LiveEditor::API::Theme.update(theme_id, asset_ids: [asset_id])
      end

      before do
        stub_request(:patch, "http://example.api.liveeditorapp.com/themes/#{theme_id}")
          .with(body: payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 200, headers: { 'Content-Type' => 'application/vnd.api+json'}, body: payload.to_json)
      end

      it 'is successful' do
        expect(response.success?).to eql true
      end

      it 'returns HTTP OK response' do
        expect(response.response).to be_a Net::HTTPOK
      end

      it 'returns the expected response payload' do
        expect(response.parsed_body).to eql payload
      end
    end # with valid input

    context 'with invalid input' do
      let(:response) do
        LiveEditor::API::Theme.update(theme_id, asset_ids: [asset_id, asset_id])
      end

      before do
        payload['data']['relationships']['assets']['data'] << {
          'type' => 'assets',
          'id' => asset_id
        }
      end

      before do
        stub_request(:patch, "http://example.api.liveeditorapp.com/themes/#{theme_id}")
          .with(body: payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 422, headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      it 'is error' do
        expect(response.error?).to eql true
      end

      it 'returns HTTP Unprocessable Entity response' do
        expect(response.response).to be_a Net::HTTPUnprocessableEntity
      end
    end # with invalid input
  end # .update
end
