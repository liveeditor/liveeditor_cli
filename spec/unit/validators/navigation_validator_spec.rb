require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::NavigationValidator, fakefs: true do
  let(:validator) { subject }

  describe '.valid?' do
    context 'with minimal valid navigation.json' do
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

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with fully-loaded valid navigation.json' do
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
                filename: 'glob'
              }
            ]
          })
        end

        FileUtils.touch(theme_root + '/navigation/glob_navigation.liquid')
      end

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with no navigation folder' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with non-JSON navigation.json' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with navigation folder'

      before do
        File.open(theme_root + '/navigation/navigation.json', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with missing navigation root element in /navigation/navigation.json' do
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

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

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

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

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

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

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

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end
  end # .valid?

  describe '#errors' do
    context 'with minimal valid navigation.json' do
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

      it 'has no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with fully-loaded valid navigation.json' do
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
                filename: 'glob'
              }
            ]
          })
        end

        FileUtils.touch(theme_root + '/navigation/glob_navigation.liquid')
      end

      it 'has no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with no navigation folder' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with non-JSON navigation.json' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with navigation folder'

      before do
        File.open(theme_root + '/navigation/navigation.json', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/navigation/navigation.json` does not contain valid JSON markup.'
      end
    end

    context 'with missing navigation root element in /navigation/navigation.json' do
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

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/navigation/navigation.json` must contain a root `navigation` attribute containing an array.'
      end
    end

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

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/navigation/navigation.json` must contain a root `navigation` attribute containing an array.'
      end
    end

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

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The navigation menu in position 1 within the file at `/navigation/navigation.json` does not have a valid `title`.'
      end
    end

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

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The navigation menu in position 1 is missing its matching Liquid template: `/navigation/global_navigation.liquid`.'
      end
    end
  end # #errors
end
