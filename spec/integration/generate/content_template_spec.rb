require 'spec_helper'

RSpec.describe LiveEditor::CLI::Generators::ContentTemplateGenerator do
  context 'within valid theme' do
    include_context 'basic theme'
    include_context 'within theme root'

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

  context 'outside of theme folder' do
    include_context 'outside of theme root'

    it 'returns an error and does not generate any files' do
      output = capture(:stdout) { subject.content_template('my_content_template') }
      expect(output).to eql "ERROR: Must be within an existing Live Editor theme's folder to run this command."
      expect(File).to_not exist(FileUtils.pwd + '/content_templates/content_templates.json')
    end
  end
end
