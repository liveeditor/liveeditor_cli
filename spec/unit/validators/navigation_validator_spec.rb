require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::NavigationValidator, fakefs: true do
  let(:validator) { subject }

  context 'with minimal valid `navigation.json`' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with navigation folder'

    before do
      File.open(theme_root + '/navigation/navigation.json', 'w') do |f|
        f.write JSON.generate({
          navigation: [
            { title: 'global' }
          ]
        })
      end

      FileUtils.touch(theme_root + '/navigation/global_navigation.liquid')
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
  end # with minimal valid `navigation.json`

  context 'with fully-loaded valid `navigation.json`' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with navigation folder'

    before do
      File.open(theme_root + '/navigation/navigation.json', 'w') do |f|
        f.write JSON.generate({
          navigation: [
            {
              title: 'global',
              var_name: 'main',
              description: 'A description.',
              file_name: 'glob'
            }
          ]
        })
      end

      FileUtils.touch(theme_root + '/navigation/glob_navigation.liquid')
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
  end # with fully-loaded valid `navigation.json`

  context 'with no navigation folder' do
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

  context 'with non-JSON `navigation.json`' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with navigation folder'

    before do
      File.open(theme_root + '/navigation/navigation.json', 'w') do |f|
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
      expect(validator.messages.first[:message]).to eql 'The file at `/navigation/navigation.json` does not contain valid JSON markup.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/navigation/navigation.json` does not contain valid JSON markup.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with non-JSON `navigation.json`

  context 'with missing navigation root element in `/navigation/navigation.json`' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with navigation folder'

    before do
      File.open(theme_root + '/navigation/navigation.json', 'w') do |f|
        f.write JSON.generate({
          nav: []
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
      expect(validator.messages.first[:message]).to eql 'The file at `/navigation/navigation.json` must contain a root `navigation` attribute containing an array.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/navigation/navigation.json` must contain a root `navigation` attribute containing an array.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with missing navigation root element in `/navigation/navigation.json`

  context 'with non-array `navigation` root element in `/navigation/navigation.json`' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with navigation folder'

    before do
      File.open(theme_root + '/navigation/navigation.json', 'w') do |f|
        f.write JSON.generate({
          navigation: {}
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
      expect(validator.messages.first[:message]).to eql 'The file at `/navigation/navigation.json` must contain a root `navigation` attribute containing an array.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/navigation/navigation.json` must contain a root `navigation` attribute containing an array.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with non-array `navigation` root element in `/navigation/navigation.json`

  context 'with missing `title` in `/navigation/navigation.json`' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with navigation folder'

    before do
      File.open(theme_root + '/navigation/navigation.json', 'w') do |f|
        f.write JSON.generate({
          navigation: [
            { var_name: 'global' }
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
      expect(validator.messages.first[:message]).to eql 'The navigation menu in position 1 within the file at `/navigation/navigation.json` does not have a valid `title`.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The navigation menu in position 1 within the file at `/navigation/navigation.json` does not have a valid `title`.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with missing `title` in `/navigation/navigation.json`

  context 'with missing Liquid template' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with navigation folder'

    before do
      File.open(theme_root + '/navigation/navigation.json', 'w') do |f|
        f.write JSON.generate({
          navigation: [
            { title: 'Global' }
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
      expect(validator.messages.first[:message]).to eql 'The navigation menu in position 1 is missing its matching Liquid template: `/navigation/global_navigation.liquid`.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The navigation menu in position 1 is missing its matching Liquid template: `/navigation/global_navigation.liquid`.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with missing Liquid template
end
