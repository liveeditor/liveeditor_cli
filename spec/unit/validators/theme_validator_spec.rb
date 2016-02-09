require 'spec_helper'

RSpec.describe LiveEditor::Cli::Validators::ThemeValidator do
  let(:validator) { LiveEditor::Cli::Validators::ThemeValidator.new }

  describe '.valid?' do
    context 'with valid theme.json' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'returns true' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with non-JSON theme.json' do
      include_context 'basic theme'

      before do
        File.open(theme_root + '/theme.json', 'w') do |f|
          f.write('bananas')
        end
      end

      include_context 'within theme root'

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with invalid theme.json title' do
      include_context 'basic theme'

      before do
        File.open(theme_root + '/theme.json', 'w') do |f|
            f.write JSON.generate({
            foo: 'bar'
          })
        end
      end

      include_context 'within theme root'

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end
  end # valid?

  describe '.errors' do
    context 'with valid theme.json' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'has no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with non-JSON theme.json' do
      include_context 'basic theme'

      before do
        File.open(theme_root + '/theme.json', 'w') do |f|
          f.write('bananas')
        end
      end

      include_context 'within theme root'

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/theme.json` does not contain valid JSON markup.'
      end
    end

    context 'with invalid theme.json title' do
      include_context 'basic theme'

      before do
        File.open(theme_root + '/theme.json', 'w') do |f|
            f.write JSON.generate({
            foo: 'bar'
          })
        end
      end

      include_context 'within theme root'

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/theme.json` must contain a `title` attribute.'
      end
    end
  end
end
