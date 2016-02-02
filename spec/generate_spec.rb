require 'spec_helper'

RSpec.describe LiveEditor::Cli::Generate do
  describe 'layout' do
    # Clean up generated my_theme directory.
    after do
      FileUtils.rm_rf(theme_root)
    end

    context 'within valid theme' do
      let(:folder)     { 'my_theme_' + (Time.now.to_f * 1000).to_i.to_s }
      let(:theme_root) { File.dirname(File.realpath(__FILE__)).sub('spec', folder) }

      before do
        Dir.mkdir(theme_root)
        Dir.mkdir(theme_root + '/layouts')

        File.open(theme_root + '/layouts/layouts.json', 'w+') do |f|
          layout_config = { layouts: [] }
          f.write(JSON.generate(layout_config))
        end

        FileUtils.cd folder
      end

      after do
        FileUtils.cd '..'
      end

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
    end
  end
end
