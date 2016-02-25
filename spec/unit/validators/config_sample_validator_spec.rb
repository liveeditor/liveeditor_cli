require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::ConfigSampleValidator, fakefs: true do
  let(:validator) { subject }

  context 'with valid `config.json.sample`' do
    include_context 'basic theme'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/config.json.sample', 'w') do |f|
        f.write JSON.generate({ admin_domain: '' })
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

  context 'with default value for `admin_domain` in `config.json.sample`' do
    include_context 'basic theme'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/config.json.sample', 'w') do |f|
        f.write JSON.generate({ admin_domain: '.liveeditorapp.com' })
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

  context 'with no config.json.sample' do
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

  context 'with non-JSON `config.json.sample`' do
    include_context 'basic theme'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/config.json.sample', 'w') do |f|
        f.write('bananas')
      end
    end

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'returns a #messages array with a warning' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :warning
    end

    it 'returns a #messages array with a message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'The file at `/config.json.sample` does not contain valid JSON markup.'
    end

    it 'returns a #warnings array with a warning' do
      validator.valid?
      expect(validator.warnings.first[:type]).to eql :warning
    end

    it 'returns a #warnings array with a warning message' do
      validator.valid?
      expect(validator.warnings.first[:message]).to eql 'The file at `/config.json.sample` does not contain valid JSON markup.'
    end

    it 'returns no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end
  end # with non-JSON `config.json.sample`

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

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'returns a #messages array with a warning' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :warning
    end

    it 'returns a #messages array with a warning message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql 'It is not recommended to store `admin_domain` in the `/config.sample.json` file.'
    end

    it 'returns a #warnings array with a warning' do
      validator.valid?
      expect(validator.warnings.first[:type]).to eql :warning
    end

    it 'returns a #warnings array with a warning message' do
      validator.valid?
      expect(validator.warnings.first[:message]).to eql 'It is not recommended to store `admin_domain` in the `/config.sample.json` file.'
    end

    it 'returns no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end
  end # with `admin_domain` in `config.json.sample`
end
