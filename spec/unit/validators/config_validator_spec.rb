require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::ConfigValidator, fakefs: true do
  let(:validator) { subject }

  describe '.valid?' do
    context 'with valid config.json' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            admin_domain: 'example.liveeditorapp.com'
          })
        end
      end

      it 'returns true' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with no config.json' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'returns true' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with non-JSON config.json' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with missing `config.json` `admin_domain`' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({})
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with empty `config.json` `admin_domain`' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            admin_domain: ''
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with default `config.json` `admin_domain`' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            admin_domain: '.liveeditorapp.com'
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end
  end # valid?

  describe '.errors' do
    context 'with valid config.json' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            admin_domain: 'example.liveeditorapp.com'
          })
        end
      end

      it 'has no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with non-JSON config.json' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/config.json` does not contain valid JSON markup.'
      end
    end

    context 'with missing `config.json` `admin_domain`' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({})
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/config.json` must contain an `admin_domain` attribute.'
      end
    end

    context 'with empty `config.json` `admin_domain`' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            admin_domain: ''
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/config.json` must contain an `admin_domain` attribute.'
      end
    end

    context 'with default `config.json` `admin_domain`' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            admin_domain: '.liveeditorapp.com'
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/config.json` must contain an `admin_domain` attribute.'
      end
    end
  end # errors
end
