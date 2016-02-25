require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::ConfigValidator, fakefs: true do
  let(:validator) { subject }

  context 'with valid `config.json`' do
    include_context 'basic theme'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/config.json', 'w') do |f|
        f.write JSON.generate({
          admin_domain: 'example.liveeditorapp.com'
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

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end

    it 'has no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end
  end

  context 'with no `config.json`' do
    include_context 'basic theme'
    include_context 'within theme root'

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql '`/config.json` has not yet been created.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql '`/config.json` has not yet been created.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with non-JSON `config.json`' do
    include_context 'basic theme'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/config.json', 'w') do |f|
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
      expect(validator.messages.first[:message]).to eql 'The file at `/config.json` does not contain valid JSON markup.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/config.json` does not contain valid JSON markup.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with non-JSON `config.json`

  context 'with missing `config.json` `admin_domain`' do
    include_context 'basic theme'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/config.json', 'w') do |f|
        f.write JSON.generate({})
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
      expect(validator.messages.first[:message]).to eql 'The file at `/config.json` must contain an `admin_domain` attribute.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/config.json` must contain an `admin_domain` attribute.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with missing `config.json` `admin_domain`

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

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The file at `/config.json` must contain an `admin_domain` attribute.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/config.json` must contain an `admin_domain` attribute.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with empty `config.json` `admin_domain`

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

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The file at `/config.json` must contain an `admin_domain` attribute.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/config.json` must contain an `admin_domain` attribute.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with default `config.json` `admin_domain`
end
