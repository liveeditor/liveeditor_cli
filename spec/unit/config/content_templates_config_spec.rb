require 'spec_helper'

RSpec.describe LiveEditor::CLI::Config::ContentTemplatesConfig, fakefs: true do
  context 'with valid JSON' do
    let(:content_templates) do
      [
        { 'title' => 'Article' }
      ]
    end

    let(:data) do
      { 'content_templates' => content_templates }
    end

    before do
      File.open('/config.json', 'w') do |f|
        f.write JSON.generate(data)
      end
    end

    it 'returns content templates' do
      config = LiveEditor::CLI::Config::ContentTemplatesConfig.new('/config.json')
      expect(config.content_templates).to eql content_templates
    end
  end

  context 'with invalid JSON' do
    let(:data) { 'banana' }

    before do
      File.open('/config.json', 'w') do |f|
        f.write data
      end
    end

    it 'returns an empty array' do
      config = LiveEditor::CLI::Config::ContentTemplatesConfig.new('/config.json')
      expect(config.content_templates).to eql []
    end
  end
end
