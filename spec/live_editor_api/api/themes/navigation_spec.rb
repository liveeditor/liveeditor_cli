require 'spec_helper'

RSpec.describe LiveEditor::API::Themes::Navigation do
  let(:client) { LiveEditor::API::Client.new(domain: 'example.liveeditorapp.com', access_token: '1234567890', refresh_token: '0987654321') }
  before { LiveEditor::API::client = client }

  describe '.create' do
    let(:content) do
      content = <<-NAV
        <nav class="global-nav">
          {% for link in navigation.links %}
            <a href="{{ link.url }}" class="global-nav-link {% if link.active? %}is-active{% endif %}">
              {{ link.title }}
            </a>
          {% endfor %}
        </nav>
      NAV

      content.strip
    end

    context 'with minimum valid input' do
      let(:response) do
        subject.class.create('Global', 'global_navigation.liquid', content)
      end

      let(:request_payload) do
        {
          data: {
            type: 'navigations',
            attributes: {
              'title' => 'Global',
              'file-name' => 'global_navigation.liquid',
              'content' => content,
              'description' => nil,
              'var-name' => nil
            }
          }
        }
      end

      let(:response_payload) do
        {
          'data' => {
            'type' => 'navigations',
            'id' => '1234',
            'attributes' => {
              'title' => 'Global',
              'file-name' => 'global_navigation.liquid',
              'content' => content,
              'description' => nil,
              'var-name' => 'global'
            }
          }
        }
      end

      before do
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/navigations')
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
    end # with minimum valid input

    context 'with fully-loaded valid input' do
      let(:response) do
        subject.class.create 'Global', 'global_navigation.liquid', content, var_name: 'glob',
                             description: 'A description.'
      end

      let(:request_payload) do
        {
          data: {
            type: 'navigations',
            attributes: {
              'title' => 'Global',
              'file-name' => 'global_navigation.liquid',
              'content' => content,
              'description' => 'A description.',
              'var-name' => 'glob'
            }
          }
        }
      end

      let(:response_payload) do
        {
          'data' => {
            'type' => 'navigations',
            'id' => '1234',
            'attributes' => {
              'title' => 'Global',
              'file-name' => 'global_navigation.liquid',
              'content' => content,
              'description' => 'A description.',
              'var-name' => 'glob'
            }
          }
        }
      end

      before do
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/navigations')
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
    end # with fully-loaded valid input

    context 'with invalid input' do
      let(:response) { subject.class.create('', 'global_navigation.liquid', content) }

      let(:request_payload) do
        {
          data: {
            type: 'navigations',
            attributes: {
              'title' => '',
              'file-name' => 'global_navigation.liquid',
              'content' => content,
              'description' => nil,
              'var-name' => nil
            }
          }
        }
      end

      let(:response_payload) do
        {
          'errors' => [
            {
              'source' => {
                'pointer' => '/data/attributes/title'
              },
              'detail' => "can't be blank"
            }
          ]
        }
      end

      before do
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/navigations')
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
          'title' => ["can't be blank"]
        })
      end
    end # with invalid input
  end # .update
end
