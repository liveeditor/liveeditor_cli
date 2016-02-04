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

          it 'creates a new default_display.liquid file' do
            output = capture(:stdout) { subject.content_template('My Content Template') }
            expect(File).to exist(theme_root + '/content_templates/my_content_template/default_display.liquid')
          end
        end

        context 'with underscored TITLE' do
          it "echoes new content template's TITLE" do
            output = capture(:stdout) { subject.content_template('my_content_template') }
            expect(output).to match /Creating a new content template titled "My Content Template".../
          end

          it 'adds the new theme entry into content_templates.json' do
            output = capture(:stdout) { subject.content_template('my_content_template') }
            content_template_config = JSON.parse(File.read(theme_root + '/content_templates/content_templates.json'))

            expect(content_template_config['content_templates'].first['title']).to eql 'My Content Template'
          end

          it 'creates a new default_display.liquid file' do
            output = capture(:stdout) { subject.content_template('my_content_template') }
            expect(File).to exist(theme_root + '/content_templates/my_content_template/default_display.liquid')
          end
        end

        context 'with blocks as arguments' do
          it 'adds blocks to content_templates.json' do
            output = capture(:stdout) { subject.content_template('my_content_template', 'title', 'photo:image', 'map:google_map') }
            content_template_config = JSON.parse(File.read(theme_root + '/content_templates/content_templates.json'))
            new_blocks = content_template_config['content_templates'].first['blocks']

            # No type provided defaults to text.
            expect(new_blocks[0]['title']).to eql 'Title'
            expect(new_blocks[0]['description']).to eql ''
            expect(new_blocks[0]['var_name']).to eql 'title'
            expect(new_blocks[0]['type']).to eql 'text'

            expect(new_blocks[1]['title']).to eql 'Photo'
            expect(new_blocks[1]['description']).to eql ''
            expect(new_blocks[1]['var_name']).to eql 'photo'
            expect(new_blocks[1]['type']).to eql 'image'

            expect(new_blocks[2]['title']).to eql 'Map'
            expect(new_blocks[2]['description']).to eql ''
            expect(new_blocks[2]['var_name']).to eql 'map'
            expect(new_blocks[2]['type']).to eql 'google_map'
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

  describe 'navigation' do
    # Clean up generated my_theme directory.
    after do
      FileUtils.rm_rf(theme_root)
    end

    context 'within valid theme' do
      let(:folder)     { 'my_theme_' + (Time.now.to_f * 1000).to_i.to_s }
      let(:theme_root) { File.dirname(File.realpath(__FILE__)).sub('integration', folder) }

      before do
        Dir.mkdir(theme_root)
        Dir.mkdir(theme_root + '/navigation')

        File.open(theme_root + '/navigation/navigation.json', 'w+') do |f|
          nav_config = { navigation: [] }
          f.write(JSON.generate(nav_config))
        end

        FileUtils.cd theme_root
      end

      after do
        FileUtils.cd '..'
      end

      context 'with titleized TITLE' do
        it "echoes new navigation menu's TITLE" do
          output = capture(:stdout) { subject.navigation('My Nav') }
          expect(output).to match /Creating a new navigation menu titled "My Nav".../
        end

        it 'adds the new menu entry into navigation.json' do
          output = capture(:stdout) { subject.navigation('My Nav') }
          nav_config = JSON.parse(File.read(theme_root + '/navigation/navigation.json'))

          expect(nav_config['navigation'].first['title']).to eql 'My Nav'
          expect(nav_config['navigation'].first['var_name']).to eql 'my_nav'
          expect(nav_config['navigation'].first['description']).to eql ''
        end

        it 'creates a new my_nav_navigation.liquid file' do
          output = capture(:stdout) { subject.navigation('My Nav') }
          expect(File).to exist(theme_root + '/navigation/my_nav_navigation.liquid')
        end
      end

      context 'with underscored TITLE' do
        it "echoes new menu's TITLE" do
          output = capture(:stdout) { subject.navigation('my_nav') }
          expect(output).to match /Creating a new navigation menu titled "My Nav".../
        end

        it 'adds the new menu entry into navigation.json' do
          output = capture(:stdout) { subject.navigation('my_nav') }
          nav_config = JSON.parse(File.read(theme_root + '/navigation/navigation.json'))

          expect(nav_config['navigation'].first['title']).to eql 'My Nav'
          expect(nav_config['navigation'].first['var_name']).to eql 'my_nav'
          expect(nav_config['navigation'].first['description']).to eql ''
        end

        it 'creates a new my_nav_navigation.liquid file' do
          output = capture(:stdout) { subject.navigation('my_nav') }
          expect(File).to exist(theme_root + '/navigation/my_nav_navigation.liquid')
        end
      end
    end # within valid theme
  end # navigation
end
