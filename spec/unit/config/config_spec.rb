require 'spec_helper'

RSpec.describe LiveEditor::CLI::Config::Config, fakefs: true do
  context 'with valid JSON content in file' do
    let(:data) do
      {
        'content_templates' => [
          { 'title' => 'Article' }
        ]
      }
    end

    before do
      File.open('/config.json', 'w') do |f|
        f.write JSON.generate(data)
      end
    end

    it 'is parsed' do
      config = LiveEditor::CLI::Config::Config.new('/config.json')
      expect(config.parsed?).to eql true
    end

    it 'contains the config hash in `config`' do
      config = LiveEditor::CLI::Config::Config.new('/config.json')
      expect(config.config).to eql data
    end
  end

  context 'with wrong `file_path`' do
    it 'is not parsed' do
      config = LiveEditor::CLI::Config::Config.new('banana')
      expect(config.parsed?).to eql false
    end
  end

  context 'with invalid JSON content in file' do
    before do
      File.open('/config.json', 'w') do |f|
        f.write 'banana'
      end
    end

    it 'is not parsed' do
      config = LiveEditor::CLI::Config::Config.new('/config.json')
      expect(config.parsed?).to eql false
    end
  end
end
