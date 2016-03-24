require 'spec_helper'

describe LiveEditor::API::OAuth do
  describe '#login' do
    context 'with valid credentials' do
      it 'returns success' do
        LiveEditor::API::client = LiveEditor::API::Client.new(domain: 'example.liveeditorapp.com')
        oauth = LiveEditor::API::OAuth.new

        stub_request(:post, 'http://example.api.liveeditorapp.com/oauth/token.json')
          .to_return(status: 200, body: {}.to_json)

        expect(oauth.login('example@example.com', 'n4ch0h4t')).to be_success
      end
    end
  end
end
