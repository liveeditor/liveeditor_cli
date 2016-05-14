require 'spec_helper'

RSpec.describe LiveEditor::API::Themes::Region do
  let(:client) do
    LiveEditor::API::Client.new domain: 'example.liveeditorapp.com', access_token: '1234567890',
                                refresh_token: '0987654321'
  end

  let(:site_id) { SecureRandom.uuid }

  before { LiveEditor::API::client = client }

  describe '.current_site' do
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
    end # with valid input
  end # .current
end
