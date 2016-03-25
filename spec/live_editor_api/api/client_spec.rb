require 'spec_helper'

RSpec.describe LiveEditor::API::Client do
  let(:client) { LiveEditor::API::Client.new(domain: 'example.liveeditorapp.com', access_token: '1234567890', refresh_token: '0987654321') }

  let(:payload) do
    {
      data: {
        title: 'My Layout',
        content: '<!DOCTYPE html>'
      }
    }
  end

  before do
    LiveEditor::API::client = client

    # Auto-refresh of OAuth token when first try to an endpoint returns
    # unauthorized.
    stub_request(:post, 'http://example.api.liveeditorapp.com/oauth/token')
      .to_return(status: 200, body: { access_token: '0987654321', refresh_token: '1234567890' }.to_json)
  end

  describe '#post' do
    context 'with successful response' do
      before do
        # First call to endpoint is successful.
        stub_request(:post, 'http://example.api.liveeditorapp.com/layouts')
          .with(body: payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 201, headers: { 'Content-Type' => 'application/vnd.api+json'}, body: payload.to_json)
      end

      it 'returns a `LiveEditor::API::Response`' do
        response = client.post('/layouts', payload: payload)
        expect(response.is_a?(LiveEditor::API::Response)).to eql true
      end

      it 'is successful' do
        response = client.post('/layouts', payload: payload)
        expect(response.success?).to eql true
      end

      it 'is JSON API' do
        response = client.post('/layouts', payload: payload)
        expect(response.json_api?).to eql true
      end

      it 'returns HTTP Created response' do
        response = client.post('/layouts', payload: payload)
        expect(response.response).to be_a Net::HTTPCreated
      end
    end # with successful response

    context 'with successful response after auto-refreshing access token' do
      before do
        # First call to endpoint is unsuccessful.
        stub_request(:post, 'http://example.api.liveeditorapp.com/layouts')
          .with(body: payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 401, headers: { 'Content-Type' => 'application/json' }, body: { error: 'Unauthorized request' }.to_json)

        # Second call to endpoint is successful.
        stub_request(:post, 'http://example.api.liveeditorapp.com/layouts')
          .with(body: payload.to_json, headers: { 'Authorization' => 'Bearer 0987654321' })
          .to_return(status: 201, headers: { 'Content-Type' => 'application/vnd.api+json'}, body: payload.to_json)
      end

      it 'returns a `LiveEditor::API::Response`' do
        response = client.post('/layouts', payload: payload)
        expect(response.is_a?(LiveEditor::API::Response)).to eql true
      end

      it 'is successful' do
        response = client.post('/layouts', payload: payload)
        expect(response.success?).to eql true
      end

      it 'is JSON API' do
        response = client.post('/layouts', payload: payload)
        expect(response.json_api?).to eql true
      end

      it 'returns HTTP Created response' do
        response = client.post('/layouts', payload: payload)
        expect(response.response).to be_a Net::HTTPCreated
      end
    end # with successful response after auto-refreshing access token

    context 'with unauthorized response' do
      before do
        # First call to endpoint is unsuccessful.
        stub_request(:post, 'http://example.api.liveeditorapp.com/layouts')
          .with(body: payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 401, headers: { 'Content-Type' => 'application/json' }, body: { error: 'Unauthorized request' }.to_json)

        # Second call to endpoint is also unsuccessful.
        stub_request(:post, 'http://example.api.liveeditorapp.com/layouts')
          .with(body: payload.to_json, headers: { 'Authorization' => 'Bearer 0987654321' })
          .to_return(status: 401, headers: { 'Content-Type' => 'application/json' }, body: { error: 'Unauthorized request' }.to_json)
      end

      it 'returns a `LiveEditor::API::Response`' do
        response = client.post('/layouts', payload: payload)
        expect(response.is_a?(LiveEditor::API::Response)).to eql true
      end

      it 'is error' do
        response = client.post('/layouts', payload: payload)
        expect(response.error?).to eql true
      end

      it 'is JSON' do
        response = client.post('/layouts', payload: payload)
        expect(response.json?).to eql true
      end

      it 'has the error' do
        response = client.post('/layouts', payload: payload)
        expect(response.errors).to eql [{ 'detail' => 'Unauthorized request' }]
      end

      it 'returns HTTP Unauthorized response' do
        response = client.post('/layouts', payload: payload)
        expect(response.response).to be_a Net::HTTPUnauthorized
      end
    end # with unauthorized response

    context 'with not found response' do
      before do
        stub_request(:post, 'http://example.api.liveeditorapp.com/layouts')
          .with(body: payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 404, body: payload.to_json)
      end

      it 'returns HTTP Not Found response' do
        response = client.post('/layouts', payload: payload)
        expect(response.response).to be_a Net::HTTPNotFound
      end
    end

    context 'with no configured client' do
      it 'raises an exception' do
        client = LiveEditor::API::Client.new
        expect { client.post('/layouts') }.to raise_error NoMethodError
      end
    end
  end # #post
end
