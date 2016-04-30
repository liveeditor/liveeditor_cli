require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::ContentTemplatesValidator, fakefs: true do
  let(:validator) { subject }

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

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'has no #messages' do
      validator.valid?
      expect(validator.messages).to eql []
    end

    it 'has no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
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
                  data_type: 'text',
                  description: "Block's description.",
                  required: false,
                  inline: false
                }
              ],
              displays: [
                {
                  title: 'Default',
                  description: "Display's description.",
                  file_name: 'the_default',
                  default: true
                }
              ]
            }
          ]
        })
      end

      Dir.mkdir(theme_root + '/content_templates/something')
      FileUtils.touch(theme_root + '/content_templates/something/the_default_display.liquid')
    end

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'has no #messages' do
      validator.valid?
      expect(validator.messages).to eql []
    end

    it 'has no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with no `content_templates` folder' do
    include_context 'basic theme'
    include_context 'within theme root'

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'has no #messages' do
      validator.valid?
      expect(validator.messages).to eql []
    end

    it 'has no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with no `content_templates.json` file' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with content_templates folder'

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'has no #messages' do
      validator.valid?
      expect(validator.messages).to eql []
    end

    it 'has no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
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

    it 'is is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The file at `/content_templates/content_templates.json` does not contain valid JSON markup.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/content_templates/content_templates.json` does not contain valid JSON markup.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with invalid `content_templates.json` root attribute' do
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

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The file at `/content_templates/content_templates.json` must contain a root `content_templates` attribute containing an array.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/content_templates/content_templates.json` must contain a root `content_templates` attribute containing an array.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with non-array `content_templates.json` root attribute' do
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

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The file at `/content_templates/content_templates.json` must contain a root `content_templates` attribute containing an array.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/content_templates/content_templates.json` must contain a root `content_templates` attribute containing an array.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with missing `title` in `content_templates.json`' do
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

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The content template in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The content template in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with blank `title` in `content_templates.json`' do
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

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The content template in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The content template in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with invalid `content_templates.json` `unique`' do
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

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'returns a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'returns a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The content template in position 1 within the file at `/content_templates/content_templates.json` does not have a valid value for `unique`.'
    end

    it 'returns an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'returns an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The content template in position 1 within the file at `/content_templates/content_templates.json` does not have a valid value for `unique`.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with non-array `blocks` in `content_templates.json`' do
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
                data_type: 'text'
              }
            }
          ]
        })
      end
    end

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's `blocks` attribute must be an array."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's `blocks` attribute must be an array."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  # This is a "duplicate" test compared to what's in `block_validator_spec.rb`
  # so we can test its integration into `ContentTemplatesValidator`.
  context 'with missing block `title` in `content_templates.json`' do
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
                  data_type: 'text'
                }
              ]
            }
          ]
        })
      end
    end

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with non-array `displays` in `content_templates.json`' do
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

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's `displays` attribute must be an array."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's `displays` attribute must be an array."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
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
              displays: [
                { title: 'Default' }
              ]
            }
          ]
        })
      end
    end

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1 is missing a matching folder at `content_templates/article`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1 is missing a matching folder at `content_templates/article`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with more than 1 default displays' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with content_templates folder'

    before do
      File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
        f.write JSON.generate({
          content_templates: [
            {
              title: 'My Content Template',
              blocks: [],
              displays: [
                {
                  title: 'Default',
                  default: true
                },
                {
                  title: 'Full Article',
                  default: true
                }
              ]
            }
          ]
        })
      end

      Dir.mkdir(theme_root + '/content_templates/my_content_template')
      FileUtils.touch(theme_root + '/content_templates/my_content_template/default_display.liquid')
      FileUtils.touch(theme_root + '/content_templates/my_content_template/full_article_display.liquid')
    end

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1 may only have 1 default display."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1 may only have 1 default display."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end
end
