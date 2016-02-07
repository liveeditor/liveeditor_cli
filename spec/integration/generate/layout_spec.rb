require 'spec_helper'

RSpec.describe LiveEditor::Cli::Generators::Layout do
  context 'within valid theme' do
    include_context 'basic theme'

    before do
      Dir.mkdir(theme_root + '/layouts')

      File.open(theme_root + '/layouts/layouts.json', 'w+') do |f|
        layout_config = { layouts: [] }
        f.write(JSON.generate(layout_config))
      end

      FileUtils.cd theme_root
    end

    after { FileUtils.cd('..') }

    context 'with titleized TITLE' do
      it "echoes new layout's TITLE" do
        output = capture(:stdout) { subject.layout('My Layout') }
        expect(output).to match /Creating a new Live Editor layout titled "My Layout".../
      end

      it 'adds the new theme entry into layouts.json' do
        output = capture(:stdout) { subject.layout('My Layout') }
        layout_config = JSON.parse(File.read(theme_root + '/layouts/layouts.json'))

        expect(layout_config['layouts'].first['title']).to eql 'My Layout'
      end

      it 'creates a new my_layout.liquid file' do
        output = capture(:stdout) { subject.layout('My Layout') }
        expect(File).to exist(theme_root + '/layouts/my_layout_layout.liquid')
      end
    end

    context 'with underscored TITLE' do
      it "echoes new layout's TITLE" do
        output = capture(:stdout) { subject.layout('my_layout') }
        expect(output).to match /Creating a new Live Editor layout titled "My Layout".../
      end

      it 'adds the new theme entry into layouts.json' do
        output = capture(:stdout) { subject.layout('my_layout') }
        layout_config = JSON.parse(File.read(theme_root + '/layouts/layouts.json'))

        expect(layout_config['layouts'].first['title']).to eql 'My Layout'
      end

      it 'creates a new my_layout.liquid file' do
        output = capture(:stdout) { subject.layout('my_layout') }
        expect(File).to exist(theme_root + '/layouts/my_layout_layout.liquid')
      end
    end
  end # within valid theme

  context 'outside of theme folder' do
    it 'returns an error and does not generate any files' do
      output = capture(:stdout) { subject.layout('my_layout') }
      expect(output).to eql "ERROR: Must be within an existing Live Editor theme's folder to run this command."
      expect(File).to_not exist(FileUtils.pwd + '/layouts/my_layout_layout.liquid')
    end
  end
end
