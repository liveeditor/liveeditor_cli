require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::LayoutsValidator, fakefs: true do
  let(:validator) { subject }

  context 'with valid minimal `layouts.json`' do
    include_context 'basic theme'
    include_context 'with layouts folder'
    include_context 'with layout Liquid template', 'my_layout'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
        f.write JSON.generate({
          layouts: [
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
  end # with valid minimal `layouts.json`

  context 'with valid fully-loaded `layouts.json`' do
    include_context 'basic theme'
    include_context 'with layouts folder'
    include_context 'with content_templates folder'
    include_context 'with layout Liquid template', 'something'
    include_context 'within theme root'

    before do
      # Content template is needed for `content_templates` array below.
      File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
        f.write JSON.generate({
          content_templates: [
            { title: 'Article' }
          ]
        })
      end

      File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
        f.write JSON.generate({
          layouts: [
            {
              title: 'My Layout',
              description: 'A description.',
              unique: true,
              file_name: 'something',
              regions: [
                {
                  title: 'Main',
                  var_name: 'main',
                  description: 'Another description.',
                  content_templates: [
                    'text',
                    'article'
                  ],
                  max_num_content: 2
                }
              ]
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
  end # with valid fully-loaded `layouts.json`

  context 'with non-JSON `layouts.json`' do
    include_context 'basic theme'
    include_context 'with layouts folder'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
        f.write('bananas')
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
      expect(validator.messages.first[:message]).to eql 'The file at `/layouts/layouts.json` does not contain valid JSON markup.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/layouts/layouts.json` does not contain valid JSON markup.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with non-JSON `layouts.json`

  context 'with invalid layouts.json root attribute' do
    include_context 'basic theme'
    include_context 'with layouts folder'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
        f.write JSON.generate({
          layout: []
        })
      end
    end

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The file at `/layouts/layouts.json` must contain a root `layouts` attribute containing an array.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/layouts/layouts.json` must contain a root `layouts` attribute containing an array.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with non-array `layouts.json` root attribute' do
    include_context 'basic theme'
    include_context 'with layouts folder'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
        f.write JSON.generate({
          layouts: {
            title: 'My Layout'
          }
        })
      end
    end

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The file at `/layouts/layouts.json` must contain a root `layouts` attribute containing an array.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/layouts/layouts.json` must contain a root `layouts` attribute containing an array.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with non-array `layouts.json` root attribute

  context 'with invalid `layouts.json` `title`' do
    include_context 'basic theme'
    include_context 'with layouts folder'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
        f.write JSON.generate({
          layouts: [
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
      expect(validator.messages.first[:message]).to eql 'The layout in position 1 within the file at `/layouts/layouts.json` does not have a valid title.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The layout in position 1 within the file at `/layouts/layouts.json` does not have a valid title.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with invalid `layouts.json` `title`

  context 'with invalid `layouts.json` `unique`' do
    include_context 'basic theme'
    include_context 'with layouts folder'
    include_context 'with layout Liquid template', 'my_layout'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
        f.write JSON.generate({
          layouts: [
            {
              title: 'My Layout',
              unique: 'bananas'
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
      expect(validator.messages.first[:message]).to eql 'The layout in position 1 within the file at `/layouts/layouts.json` does not have a valid value for `unique`.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The layout in position 1 within the file at `/layouts/layouts.json` does not have a valid value for `unique`.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with invalid `layouts.json` `unique`

  context 'with non-array `layouts.json` `regions`' do
    include_context 'basic theme'
    include_context 'with layouts folder'
    include_context 'with layout Liquid template', 'my_layout'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
        f.write JSON.generate({
          layouts: [
            {
              title: 'My Layout',
              regions: {
                title: 'Main'
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
      expect(validator.messages.first[:message]).to eql "The layout in position 1's `regions` attribute must be an array."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The layout in position 1's `regions` attribute must be an array."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with non-array `layouts.json` `regions`

  # This test is a "duplicate" of a similar one in `region_validator_spec.rb`
  # to make sure that region errors are integrated properly into this
  # `LayoutsValidtor`.
  context 'with missing region `title`' do
    include_context 'basic theme'
    include_context 'with layouts folder'
    include_context 'with layout Liquid template', 'my_layout'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
        f.write JSON.generate({
          layouts: [
            {
              title: 'My Layout',
              regions: [
                {}
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
      expect(validator.messages.first[:message]).to eql "The layout in position 1's region in position 1 must have a `title`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The layout in position 1's region in position 1 must have a `title`."
    end

    it 'has a no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with missing region `title`
end
