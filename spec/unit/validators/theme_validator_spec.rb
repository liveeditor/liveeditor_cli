require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::ThemeValidator, fakefs: true do
  let(:validator) { subject }

  context 'with valid `theme.json`' do
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

  context 'with non-JSON `theme.json`' do
    include_context 'basic theme'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/theme.json', 'w') do |f|
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
      expect(validator.messages.first[:message]).to eql 'The file at `/theme.json` does not contain valid JSON markup.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/theme.json` does not contain valid JSON markup.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with missing `theme.json` `title`' do
    include_context 'basic theme'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/theme.json', 'w') do |f|
        f.write JSON.generate({ foo: 'bar' })
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
      expect(validator.messages.first[:message]).to eql 'The file at `/theme.json` must contain a `title` attribute.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/theme.json` must contain a `title` attribute.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with empty `theme.json` `title`' do
    include_context 'basic theme'
    include_context 'within theme root'

    before do
      File.open(theme_root + '/theme.json', 'w') do |f|
        f.write JSON.generate({ title: '' })
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
      expect(validator.messages.first[:message]).to eql 'The file at `/theme.json` must contain a `title` attribute.'
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql 'The file at `/theme.json` must contain a `title` attribute.'
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end
end
