require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::ConfigSampleValidator do
  let(:validator) { LiveEditor::CLI::Validators::ConfigSampleValidator.new }

  describe '.valid?' do
    context 'with valid config.json.sample' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json.sample', 'w') do |f|
          f.write JSON.generate({ admin_domain: '' })
        end
      end

      it 'returns true' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with default value for `admin_domain` in `config.json.sample`' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json.sample', 'w') do |f|
          f.write JSON.generate({ admin_domain: '.liveeditorapp.com' })
        end
      end

      it 'returns true' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with no config.json.sample' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'returns true' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with non-JSON config.json.sample' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json.sample', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with `admin_domain` in `config.json.sample`' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json.sample', 'w') do |f|
          f.write JSON.generate({
            admin_domain: 'example.liveeditorapp.com'
          })
        end
      end

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end
  end # valid?

  describe '#errors' do
    context 'with valid config.json.sample' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json.sample', 'w') do |f|
          f.write JSON.generate({ admin_domain: '' })
        end
      end

      it 'has no errors' do
        validator.valid?
        expect(validator.errors.select { |error| error[:type] == :error }).to eql []
      end
    end

    context 'with non-JSON config.json.sample' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json.sample', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'returns an array with a notice' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :warning
      end

      it 'returns an array with a notice message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/config.json.sample` does not contain valid JSON markup.'
      end
    end

    context 'with `admin_domain` in `config.json.sample`' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json.sample', 'w') do |f|
          f.write JSON.generate({ admin_domain: 'example.liveeditorapp.com' })
        end
      end

      it 'returns an array with a notice' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :warning
      end

      it 'returns an array with a notice message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'It is not recommended to store `admin_domain` in the `/config.sample.json` file.'
      end
    end

    context 'with default admin_domain in config.json.sample' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/config.json.sample', 'w') do |f|
          f.write JSON.generate({ admin_domain: '.liveeditorapp.com' })
        end
      end

      it 'returns an array with no messages' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end
  end # errors
end
