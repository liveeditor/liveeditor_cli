require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::AssetsValidator, fakefs: true do
  let(:validator) { subject }

  context 'with no `assets` folder' do
    include_context 'basic theme'
    include_context 'within theme root'

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'returns no #messages' do
      validator.valid?
      expect(validator.messages).to eql []
    end

    it 'returns no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end

    it 'returns no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with empty `assets` folder' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with assets folder'

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'returns no #messages' do
      validator.valid?
      expect(validator.messages).to eql []
    end

    it 'returns no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end

    it 'returns no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with valid files within `assets` folder' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with assets folder'

    before do
      Dir.mkdir(theme_root + '/assets/images')
      FileUtils.touch(theme_root + '/assets/images/logo.png')

      Dir.mkdir(theme_root + '/assets/js')
      FileUtils.touch(theme_root + '/assets/js/site.min.js')

      Dir.mkdir(theme_root + '/assets/css')
      FileUtils.touch(theme_root + '/assets/css/site.min.css')
    end

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'returns no #messages' do
      validator.valid?
      expect(validator.messages).to eql []
    end

    it 'returns no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end

    it 'returns no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with valid files within `assets` folder

  context 'with `scss` file included in `assets` folder' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with assets folder'

    before do
      Dir.mkdir(theme_root + '/assets/scss')
      FileUtils.touch(theme_root + '/assets/scss/site.scss')
    end

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'returns an array of #messages with a warning' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :warning
    end

    it 'returns an array of #messages with a message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The file at `/assets/scss/site.scss` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
    end

    it 'returns an array of #warnings with a warning' do
      validator.valid?
      expect(validator.warnings.first[:type]).to eql :warning
    end

    it 'returns an array of #warnings with a message' do
      validator.valid?
      expect(validator.warnings.first[:message]).to eql "The file at `/assets/scss/site.scss` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
    end

    it 'returns no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end
  end # with `scss` file included in `assets` folder

  context 'with `sass` file included in `assets` folder' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with assets folder'

    before do
      Dir.mkdir(theme_root + '/assets/sass')
      FileUtils.touch(theme_root + '/assets/sass/site.sass')
    end

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'returns an array of #messages with a warning' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :warning
    end

    it 'returns an array of #messages with a message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The file at `/assets/sass/site.sass` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
    end

    it 'returns an array of #warnings with a warning' do
      validator.valid?
      expect(validator.warnings.first[:type]).to eql :warning
    end

    it 'returns an array of #warnings with a message' do
      validator.valid?
      expect(validator.warnings.first[:message]).to eql "The file at `/assets/sass/site.sass` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
    end

    it 'returns no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end
  end # with `sass` file included in `assets` folder

  context 'with `less` file included in assets folder' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with assets folder'

    before do
      Dir.mkdir(theme_root + '/assets/less')
      FileUtils.touch(theme_root + '/assets/less/site.less')
    end

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'returns an array of #messages with a warning' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :warning
    end

    it 'returns an array of #messages with a message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The file at `/assets/less/site.less` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
    end

    it 'returns an array of #warnings with a warning' do
      validator.valid?
      expect(validator.warnings.first[:type]).to eql :warning
    end

    it 'returns an array of #warnings with a message' do
      validator.valid?
      expect(validator.warnings.first[:message]).to eql "The file at `/assets/less/site.less` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
    end

    it 'returns no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end
  end # with `less` file included in assets folder

  context 'with `coffee` file included in assets folder' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with assets folder'

    before do
      Dir.mkdir(theme_root + '/assets/js')
      FileUtils.touch(theme_root + '/assets/js/site.coffee')
    end

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'returns an array of #messages with a warning' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :warning
    end

    it 'returns an array of #messages with a message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The file at `/assets/js/site.coffee` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
    end

    it 'returns an array of #warnings with a warning' do
      validator.valid?
      expect(validator.warnings.first[:type]).to eql :warning
    end

    it 'returns an array of #warnings with a message' do
      validator.valid?
      expect(validator.warnings.first[:message]).to eql "The file at `/assets/js/site.coffee` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
    end

    it 'returns no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end
  end # with `coffee` file included in assets folder

  context 'with `ts` file included in assets folder' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with assets folder'

    before do
      Dir.mkdir(theme_root + '/assets/js')
      FileUtils.touch(theme_root + '/assets/js/site.ts')
    end

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'returns an array of #messages with a warning' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :warning
    end

    it 'returns an array of #messages with a message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The file at `/assets/js/site.ts` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
    end

    it 'returns an array of #warnings with a warning' do
      validator.valid?
      expect(validator.warnings.first[:type]).to eql :warning
    end

    it 'returns an array of #warnings with a message' do
      validator.valid?
      expect(validator.warnings.first[:message]).to eql "The file at `/assets/js/site.ts` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
    end

    it 'returns no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end
  end # with `ts` file included in assets folder
end
