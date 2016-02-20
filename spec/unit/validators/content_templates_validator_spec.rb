require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::ContentTemplatesValidator do
  let(:validator) { subject }

  describe '.valid?' do
    context 'with valid minimal content_templates.json' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Layout'
              }
            ]
          })
        end
      end

      it 'returns true' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with valid fully-loaded content_templates.json' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Content Template',
                var_name: 'a_var_name',
                description: 'A description.',
                unique: true,
                folder_name: 'something',
                blocks: [
                  {
                    title: 'Title',
                    var_name: 'another_var_name',
                    type: 'text',
                    description: "Block's description.",
                    required: false,
                    inline: false
                  }
                ],
                displays: [
                  {
                    title: 'Default',
                    description: "Display's description.",
                    filename: 'the_default'
                  }
                ]
              }
            ]
          })
        end

        Dir.mkdir(theme_root + '/content_templates/a_var_name')
        FileUtils.touch(theme_root + '/content_templates/a_var_name/the_default_display.liquid')
      end

      it 'returns true' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with no content_templates folder' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with no content_templates.json file' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with non-JSON content_templates.json file' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with invalid content_templates.json root attribute' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_template: []
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with non-array content_templates.json root attribute' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: {
              title: 'Blog Post'
            }
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with missing title in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                var_name: 'blog_post'
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with blank title in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: ''
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with invalid content_templates.json unique' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Blog Post',
                unique: 'bananas'
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with non-array blocks in content_templates.json' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Blog Post',
                blocks: {
                  title: 'Title',
                  type: 'text'
                }
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with missing block title in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    type: 'text'
                  }
                ]
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with blank block title in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    title: '',
                    type: 'text'
                  }
                ]
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with missing block type in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    title: 'My Block'
                  }
                ]
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with blank block type in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    title: 'My Block',
                    type: ''
                  }
                ]
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with non-boolean block required in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    title: 'My Block',
                    type: 'text',
                    required: 'bananas'
                  }
                ]
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with non-boolean block `inline` in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    title: 'My Block',
                    type: 'text',
                    inline: 'bananas'
                  }
                ]
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with non-array `displays` in content_templates.json' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Blog Post',
                displays: {
                  title: 'Title'
                }
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with non-array `displays` in content_templates.json' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Blog Post',
                displays: {
                  title: 'Title'
                }
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with display and no matching subfolder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Article',
                displays: {
                  title: 'Default'
                }
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with display and no matching Liquid template' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Article',
                displays: {
                  title: 'Default'
                }
              }
            ]
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end
  end # .valid?

  describe '#errors' do
    context 'with no content_templates folder' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'returns no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with no content_templates.json file' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      it 'returns no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with non-JSON content_templates.json file' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/content_templates/content_templates.json` does not contain valid JSON markup.'
      end
    end

    context 'with invalid content_templates.json root attribute' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_template: []
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/content_templates/content_templates.json` must contain a root `content_templates` attribute containing an array.'
      end
    end

    context 'with non-array content_templates.json root attribute' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: {
              title: 'Blog Post'
            }
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/content_templates/content_templates.json` must contain a root `content_templates` attribute containing an array.'
      end
    end

    context 'with missing title in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                var_name: 'blog_post'
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The content template in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`.'
      end
    end

    context 'with blank title in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: ''
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The content template in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`.'
      end
    end

    context 'with invalid content_templates.json unique' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Blog Post',
                unique: 'bananas'
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The content template in position 1 within the file at `/content_templates/content_templates.json` does not have a valid value for `unique`.'
      end
    end

    context 'with non-array blocks in content_templates.json' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Blog Post',
                blocks: {
                  title: 'Title'
                }
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The content template in position 1's `blocks` attribute must be an array."
      end
    end

    context 'with missing block title in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    var_name: 'my_block'
                  }
                ]
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`."
      end
    end

    context 'with blank block title in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    title: ''
                  }
                ]
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`."
      end
    end

    context 'with missing block type in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    title: 'My Block'
                  }
                ]
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `type`."
      end
    end

    context 'with blank block type in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    title: 'My Block',
                    type: ''
                  }
                ]
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `type`."
      end
    end

    context 'with non-boolean block required in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    title: 'My Block',
                    type: 'text',
                    required: 'bananas'
                  }
                ]
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `required`."
      end
    end

    context 'with non-boolean block `inline` in content_templates.json' do
      include_context 'basic theme'
      include_context 'with content_templates folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'My Theme',
                blocks: [
                  {
                    title: 'My Block',
                    type: 'text',
                    inline: 'bananas'
                  }
                ]
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `inline`."
      end
    end

    context 'with non-array `displays` in content_templates.json' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Blog Post',
                displays: {
                  title: 'Title'
                }
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The content template in position 1's `displays` attribute must be an array."
      end
    end

    context 'with display and no matching subfolder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Article',
                displays: [
                  { title: 'Default' }
                ]
              }
            ]
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The content template in position 1 is missing a matching folder at `content_templates/article`."
      end
    end

    context 'with display and no matching Liquid template' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with content_templates folder'

      before do
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Article',
                displays: [
                  {
                    title: 'Default'
                  }
                ]
              }
            ]
          })
        end

        Dir.mkdir(theme_root + '/content_templates/article')
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The content template in position 1's display in position 1 within the file at `/content_templates/content_templates.json` is missing its matching Liquid template at `/content_templates/article/default_display.liquid`."
      end
    end
  end # #errors
end
