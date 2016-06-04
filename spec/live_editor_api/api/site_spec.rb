require 'spec_helper'

RSpec.describe LiveEditor::API::Themes::Region do
  let(:client) do
    LiveEditor::API::Client.new domain: 'example.liveeditorapp.com', access_token: '1234567890',
                                refresh_token: '0987654321'
  end

  let(:site_id) { SecureRandom.uuid }

  before { LiveEditor::API::client = client }

  describe '.current' do
    context 'plain old request' do
      let(:response) { LiveEditor::API::Site::current }

      let(:response_payload) do
        {
          'data' => {
            'type' => 'sites',
            'id' => site_id,
            'attributes' => {
              'title' => 'Example Site',
              'subdomain-slug' => 'example'
            }
          },
          'relationships' => {
            'theme' => {
              'data' => nil
            }
          }
        }
      end

      before do
        stub_request(:get, "http://example.api.liveeditorapp.com/site")
          .with(headers: { 'Authorization' => 'Bearer 1234567890' })
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
    end # plain old request
  end # .current

  describe '.update' do
    let(:theme_id) { SecureRandom.uuid }

    let(:payload) do
      {
        'data' => {
          'type' => 'sites',
          'attributes' => {
            'title' => 'Springfield Zoo',
            'subdomain-slug' => 'springfieldzoo'
          },
          'relationships' => {
            'theme' => {
              'data' => {
                'type' => 'themes',
                'id' => theme_id
              }
            }
          }
        }
      }
    end

    context 'with valid input' do
      let(:response) do
        LiveEditor::API::Site.update title: 'Springfield Zoo', subdomain_slug: 'springfieldzoo',
                                     theme_id: theme_id
      end

      before do
        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
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
        LiveEditor::API::Site.update title: 'Springfield Zoo', subdomain_slug: 'springfieldzoo',
                                     theme_id: theme_id
      end

      let(:response_payload) do
        {
          'errors' => [
            {
              'source' => {
                'pointer' => '/data/attributes/subdomain-slug'
              },
              'detail' => 'has already been taken'
            }
          ]
        }
      end

      before do
        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .with(body: payload.to_json, headers: { 'Authorization' => 'Bearer 1234567890' })
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
          'subdomain-slug' => ['has already been taken']
        })
      end
    end # with invalid input
  end
end
