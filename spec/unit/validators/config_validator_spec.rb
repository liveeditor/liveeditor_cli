require 'spec_helper'

RSpec.describe LiveEditor::Cli::Validators::ConfigValidator do
  let(:validator) { LiveEditor::Cli::Validators::ConfigValidator.new }

  describe '.valid?' do
    context 'with valid config.json' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            api_key: '1234567890',
            secret_key: '0987654321',
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
        expect(validator.valid?).to eql true
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

    context 'with invalid config.json api_key' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            secret_key: '0987654321',
            admin_domain: 'example.liveeditorapp.com'
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with invalid config.json secret_key' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            api_key: '1234567890',
            admin_domain: 'example.liveeditorapp.com'
          })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with invalid config.json admin_domain' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            api_key: '1234567890',
            secret_key: '0987654321'
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
            api_key: '1234567890',
            secret_key: '0987654321',
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

    context 'with invalid config.json api_key' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            secret_key: '0987654321',
            admin_domain: 'example.liveeditorapp.com'
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/config.json` must contain an `api_key` attribute.'
      end
    end

    context 'with invalid config.json secret_key' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            api_key: '1234567890',
            admin_domain: 'example.liveeditorapp.com'
          })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/config.json` must contain a `secret_key` attribute.'
      end
    end

    context 'with invalid config.json admin_domain' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json', 'w') do |f|
          f.write JSON.generate({
            api_key: '1234567890',
            secret_key: '0987654321'
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
