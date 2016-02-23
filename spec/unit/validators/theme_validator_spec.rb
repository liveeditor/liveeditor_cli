require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::ThemeValidator, fakefs: true do
  let(:validator) { subject }

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
      include_context 'within theme root'

      before do
        File.open(theme_root + '/theme.json', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with missing theme.json title' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/theme.json', 'w') do |f|
          f.write JSON.generate({ foo: 'bar' })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end

    context 'with empty theme.json title' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/theme.json', 'w') do |f|
          f.write JSON.generate({ title: '' })
        end
      end

      it 'is invalid' do
        expect(validator.valid?).to eql false
      end
    end
  end # valid?

  describe '#errors' do
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
      include_context 'within theme root'

      before do
        File.open(theme_root + '/theme.json', 'w') do |f|
          f.write('bananas')
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/theme.json` does not contain valid JSON markup.'
      end
    end

    context 'with missing theme.json title' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/theme.json', 'w') do |f|
          f.write JSON.generate({ foo: 'bar' })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/theme.json` must contain a `title` attribute.'
      end
    end

    context 'with empty theme.json title' do
      include_context 'basic theme'
      include_context 'within theme root'

      before do
        File.open(theme_root + '/theme.json', 'w') do |f|
          f.write JSON.generate({ title: '' })
        end
      end

      it 'returns an array with an error' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :error
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql 'The file at `/theme.json` must contain a `title` attribute.'
      end
    end
  end # errors
end
