require 'spec_helper'

RSpec.describe LiveEditor::API do
  describe '.client' do
    it 'returns configured client' do
      client = LiveEditor::API::Client.new
      LiveEditor::API::client = client
      expect(LiveEditor::API::client).to eql client
    end
  end
end
