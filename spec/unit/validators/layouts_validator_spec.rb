require 'spec_helper'

RSpec.describe LiveEditor::Cli::Validators::LayoutsValidator do
  let(:validator) { LiveEditor::Cli::Validators::LayoutsValidator.new }

  describe '.valid?' do
    context 'with valid minimal layouts.json' do
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

      it 'returns true' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with valid fully-loaded layouts.json' do
      include_context 'basic theme'
      include_context 'with layouts folder'
      include_context 'with layout Liquid template', 'something'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
          f.write JSON.generate({
            layouts: [
              {
                title: 'My Layout',
                description: 'A description.',
                unique: true,
                filename: 'something',
                regions: [
                  {
                    title: 'Main',
                    var_name: 'main',
                    description: 'Another description.',
                    content_templates: ['text'],
                    max_num_content: 2
                  }
                ]
              }
            ]
          })
        end
      end

      it 'returns true' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with non-JSON layouts.json' do
      include_context 'basic theme'
      include_context 'with layouts folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

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

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with non-array layouts.json root attribute' do
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

      it 'is invalid' do
        expect(validator.valid?).to eql false
        expect(validator.errors.first[:type]).to eql :error
      end
    end

    context 'with invalid layouts.json title' do
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

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with invalid layouts.json unique' do
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

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with non-array layouts.json regions' do
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

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with missing region title' do
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

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with empty region title' do
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
                  {
                    title: ''
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

    context 'with non-array region content_templates' do
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
                  {
                    title: 'Main',
                    content_templates: 'text'
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

    context 'with non-integer region max_num_content' do
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
                  {
                    title: 'Main',
                    max_num_content: 'bananas'
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
  end # valid?

  describe '#errors' do
    context 'with valid minimal layouts.json' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with layouts folder'
      include_context 'with layout Liquid template', 'my_layout'

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

      it 'has no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with valid fully-loaded layouts.json' do
      include_context 'basic theme'
      include_context 'with layouts folder'
      include_context 'with layout Liquid template', 'something'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
          f.write JSON.generate({
            layouts: [
              {
                title: 'My Layout',
                description: 'A description.',
                unique: true,
                filename: 'something',
                regions: [
                  {
                    title: 'Main',
                    var_name: 'main',
                    description: 'Another description.',
                    content_templates: ['text'],
                    max_num_content: 2
                  }
                ]
              }
            ]
          })
        end
      end

      it 'has no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with non-JSON layouts.json' do
      include_context 'basic theme'
      include_context 'with layouts folder'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/layouts/layouts.json` does not contain valid JSON markup.'
      end
    end

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

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/layouts/layouts.json` must contain a root `layouts` attribute containing an array.'
      end
    end

    context 'with non-array layouts.json root attribute' do
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

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/layouts/layouts.json` must contain a root `layouts` attribute containing an array.'
      end
    end

    context 'with invalid layouts.json title' do
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

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The layout in position 1 within the file at `/layouts/layouts.json` does not have a valid title.'
      end
    end

    context 'with invalid layouts.json unique' do
      include_context 'basic theme'
      include_context 'with layouts folder'
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

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The layout in position 1 within the file at `/layouts/layouts.json` does not have a valid value for `unique`.'
      end
    end

    context 'with non-array layouts.json regions' do
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

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The layout in position 1's `regions` attribute must be an array."
      end
    end

    context 'with missing region title' do
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

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The layout in position 1's region in position 1 must have a `title`."
      end
    end # with missing region title

    context 'with empty region title' do
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
        expect(validator.errors.first[:message]).to eql "The layout in position 1's region in position 1 must have a `title`."
      end
    end # with empty region title

    context 'with non-array region content_templates' do
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
                  {
                    title: 'Main',
                    content_templates: 'text'
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
        expect(validator.errors.first[:message]).to eql "The layout in position 1's region in position 1 has an invalid `content_templates` attribute: must be an array."
      end
    end # with non-array region content_templates

    context 'with non-integer region max_num_content' do
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
                  {
                    title: 'Main',
                    max_num_content: 'bananas'
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
        expect(validator.errors.first[:message]).to eql "The layout in position 1's region in position 1 has an invalid `max_num_content` attribute: must be an integer."
      end
    end # with non-integer region max_num_content
  end # errors
end
