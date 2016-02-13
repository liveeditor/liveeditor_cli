require 'spec_helper'

RSpec.describe LiveEditor::Cli::Validators::AssetsValidator do
  let(:validator) { subject }

  describe '.valid?' do
    context 'with no assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with empty assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with valid files within assets folder' do
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

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with `scss` file included in assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      before do
        Dir.mkdir(theme_root + '/assets/scss')
        FileUtils.touch(theme_root + '/assets/scss/site.scss')
      end

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with `sass` file included in `assets` folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      before do
        Dir.mkdir(theme_root + '/assets/sass')
        FileUtils.touch(theme_root + '/assets/sass/site.sass')
      end

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with `less` file included in assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      before do
        Dir.mkdir(theme_root + '/assets/less')
        FileUtils.touch(theme_root + '/assets/less/site.less')
      end

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with `coffee` file included in assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      before do
        Dir.mkdir(theme_root + '/assets/js')
        FileUtils.touch(theme_root + '/assets/js/site.coffee')
      end

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end

    context 'with `ts` file included in assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      before do
        Dir.mkdir(theme_root + '/assets/js')
        FileUtils.touch(theme_root + '/assets/js/site.ts')
      end

      it 'is valid' do
        expect(validator.valid?).to eql true
      end
    end
  end # .valid?

  describe '#errors' do
    context 'with no assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'returns no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with empty assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      it 'returns no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with valid files within assets folder' do
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

      it 'returns no errors' do
        validator.valid?
        expect(validator.errors).to eql []
      end
    end

    context 'with `scss` file included in `assets` folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      before do
        Dir.mkdir(theme_root + '/assets/scss')
        FileUtils.touch(theme_root + '/assets/scss/site.scss')
      end

      it 'returns an array with a warning' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :warning
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The file at `/assets/scss/site.scss` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
      end
    end

    context 'with `sass` file included in `assets` folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      before do
        Dir.mkdir(theme_root + '/assets/sass')
        FileUtils.touch(theme_root + '/assets/sass/site.sass')
      end

      it 'returns an array with a warning' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :warning
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The file at `/assets/sass/site.sass` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
      end
    end

    context 'with `less` file included in assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      before do
        Dir.mkdir(theme_root + '/assets/less')
        FileUtils.touch(theme_root + '/assets/less/site.less')
      end

      it 'returns an array with a warning' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :warning
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The file at `/assets/less/site.less` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
      end
    end

    context 'with `coffee` file included in assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      before do
        Dir.mkdir(theme_root + '/assets/js')
        FileUtils.touch(theme_root + '/assets/js/site.coffee')
      end

      it 'returns an array with a warning' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :warning
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The file at `/assets/js/site.coffee` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
      end
    end

    context 'with `ts` file included in assets folder' do
      include_context 'basic theme'
      include_context 'within theme root'
      include_context 'with assets folder'

      before do
        Dir.mkdir(theme_root + '/assets/js')
        FileUtils.touch(theme_root + '/assets/js/site.ts')
      end

      it 'returns an array with a warning' do
        validator.valid?
        expect(validator.errors.first[:type]).to eql :warning
      end

      it 'returns an array with an error message' do
        validator.valid?
        expect(validator.errors.first[:message]).to eql "The file at `/assets/js/site.ts` is a source file. In most cases, we recommend moving this outside of the `/assets` folder."
      end
    end
  end # #errors
end
