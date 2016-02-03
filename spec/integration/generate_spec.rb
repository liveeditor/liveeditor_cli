require 'spec_helper'

RSpec.describe LiveEditor::Cli::Generate do
  describe 'content_template' do
    # Clean up generated my_theme directory.
    after do
      FileUtils.rm_rf(theme_root)
    end

    context 'within valid theme' do
      let(:folder)     { 'my_theme_' + (Time.now.to_f * 1000).to_i.to_s }
      let(:theme_root) { File.dirname(File.realpath(__FILE__)).sub('integration', folder) }

      before do
        Dir.mkdir(theme_root)
        FileUtils.cd theme_root
      end

      after do
        FileUtils.cd '..'
      end

      context 'with no content_templates folder' do
        it 'creates a content_templates folder' do
          output = capture(:stdout) { subject.content_template('My Content Template') }
          expect(File).to exist theme_root + '/content_templates'
        end
      end

      context 'with content_templates folder' do
        before do
          Dir.mkdir(theme_root + '/content_templates')

          File.open(theme_root + '/content_templates/content_templates.json', 'w+') do |f|
            content_template_config = { content_templates: [] }
            f.write(JSON.generate(content_template_config))
          end
        end

        context 'with titleized TITLE' do
          it "echoes new content template's TITLE" do
            output = capture(:stdout) { subject.content_template('My Content Template') }
            expect(output).to match /Creating a new content template titled "My Content Template".../
          end

          it 'adds the new content template entry into content_templates.json' do
            output = capture(:stdout) { subject.content_template('My Content Template') }
            content_template_config = JSON.parse(File.read(theme_root + '/content_templates/content_templates.json'))

            expect(content_template_config['content_templates'].first['title']).to eql 'My Content Template'
          end

          it 'creates a new my_content_template_display.liquid file' do
            output = capture(:stdout) { subject.content_template('My Content Template') }
            expect(File).to exist(theme_root + '/content_templates/my_content_template/default_display.liquid')
          end
        end

        context 'with underscored TITLE' do
          it "echoes new layout's TITLE" do
            output = capture(:stdout) { subject.content_template('my_content_template') }
            expect(output).to match /Creating a new content template titled "My Content Template".../
          end

          it 'adds the new theme entry into layouts.json' do
            output = capture(:stdout) { subject.content_template('my_content_template') }
            layout_config = JSON.parse(File.read(theme_root + '/content_templates/content_templates.json'))

            expect(layout_config['content_templates'].first['title']).to eql 'My Content Template'
          end

          it 'creates a new my_layout.liquid file' do
            output = capture(:stdout) { subject.content_template('my_content_template') }
            expect(File).to exist(theme_root + '/content_templates/my_content_template/default_display.liquid')
          end
        end
      end
    end # within valid theme
  end # content_template

  describe 'layout' do
    # Clean up generated my_theme directory.
    after do
      FileUtils.rm_rf(theme_root)
    end

    context 'within valid theme' do
      let(:folder)     { 'my_theme_' + (Time.now.to_f * 1000).to_i.to_s }
      let(:theme_root) { File.dirname(File.realpath(__FILE__)).sub('integration', folder) }

      before do
        Dir.mkdir(theme_root)
        Dir.mkdir(theme_root + '/layouts')

        File.open(theme_root + '/layouts/layouts.json', 'w+') do |f|
          layout_config = { layouts: [] }
          f.write(JSON.generate(layout_config))
        end

        FileUtils.cd theme_root
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
    end # within valid theme
  end # layout
end
