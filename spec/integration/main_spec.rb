require 'spec_helper'

RSpec.describe LiveEditor::CLI::Main do
  describe 'version' do
    it 'returns the current version number' do
      output = capture(:stdout) { subject.version }
      expect(output).to eql "Live Editor CLI v#{LiveEditor::CLI::VERSION}"
    end
  end

  describe 'new' do
    context 'with underscored TITLE' do
      it "echoes new theme's TITLE" do
        output = capture(:stdout) { subject.new('my_theme') }
        expect(output).to match /Creating a new Live Editor theme titled "My Theme".../

        # Clean up generated my_theme directory.
        FileUtils.rm_rf(File.dirname(File.realpath(__FILE__)).sub('integration', 'my_theme'))
      end

      it 'creates a `my_theme` folder with the correct contents' do
        output = capture(:stdout) { subject.new('my_theme') }

        # Check that correct files were generated.
        theme_root = File.dirname(File.realpath(__FILE__)).sub('integration', 'my_theme')
        expect(File).to exist "#{theme_root}/assets/css/site.css"
        expect(File).to exist "#{theme_root}/assets/fonts/.keep"
        expect(File).to exist "#{theme_root}/assets/images/.keep"
        expect(File).to exist "#{theme_root}/assets/js/init.js"
        expect(File).to exist "#{theme_root}/assets/js/site.js"
        expect(File).to exist "#{theme_root}/content_templates/.keep"
        expect(File).to exist "#{theme_root}/includes/.keep"
        expect(File).to exist "#{theme_root}/layouts/layouts.json"
        expect(File).to exist "#{theme_root}/layouts/site_layout.liquid"
        expect(File).to exist "#{theme_root}/navigation/global_navigation.liquid"
        expect(File).to exist "#{theme_root}/navigation/navigation.json"
        expect(File).to exist "#{theme_root}/.gitignore"
        expect(File).to exist "#{theme_root}/config.json.sample"
        expect(File).to exist "#{theme_root}/README.md"
        expect(File).to exist "#{theme_root}/theme.json"

        # Check that template files were generated and parsed correctly.
        expect(IO.read("#{theme_root}/README.md")).to match /^# My Theme/
        expect(IO.read("#{theme_root}/theme.json")).to match /"title": "My Theme"/

        # Clean up generated my_theme directory.
        FileUtils.rm_rf(File.dirname(File.realpath(__FILE__)).sub('integration', 'my_theme'))
      end
    end # with underscored TITLE

    context 'with titleized TITLE' do
      it "echoes new theme's name when titleized" do
        output = capture(:stdout) { subject.new('My Theme') }
        expect(output).to match /Creating a new Live Editor theme titled "My Theme".../

        # Clean up generated my_theme directory.
        FileUtils.rm_rf(File.dirname(File.realpath(__FILE__)).sub('integration', 'my_theme'))
      end

      it 'creates a `my_theme` folder with the correct contents' do
        output = capture(:stdout) { subject.new('My Theme') }

        # Check that correct files were generated.
        theme_root = File.dirname(File.realpath(__FILE__)).sub('integration', 'my_theme')
        expect(File).to exist "#{theme_root}/assets/css/site.css"
        expect(File).to exist "#{theme_root}/assets/fonts/.keep"
        expect(File).to exist "#{theme_root}/assets/images/.keep"
        expect(File).to exist "#{theme_root}/assets/js/init.js"
        expect(File).to exist "#{theme_root}/assets/js/site.js"
        expect(File).to exist "#{theme_root}/content_templates/.keep"
        expect(File).to exist "#{theme_root}/includes/.keep"
        expect(File).to exist "#{theme_root}/layouts/layouts.json"
        expect(File).to exist "#{theme_root}/layouts/site_layout.liquid"
        expect(File).to exist "#{theme_root}/navigation/global_navigation.liquid"
        expect(File).to exist "#{theme_root}/navigation/navigation.json"
        expect(File).to exist "#{theme_root}/.gitignore"
        expect(File).to exist "#{theme_root}/config.json.sample"
        expect(File).to exist "#{theme_root}/README.md"
        expect(File).to exist "#{theme_root}/theme.json"

        # Check that template files were generated and parsed correctly.
        expect(IO.read("#{theme_root}/README.md")).to match /^# My Theme/
        expect(IO.read("#{theme_root}/theme.json")).to match /"title": "My Theme"/

        # Clean up generated my_theme directory.
        FileUtils.rm_rf(theme_root)
      end
    end # with titleized TITLE

    context 'within existing theme' do
      include_context 'basic theme'
      before { FileUtils.cd(theme_root) }
      after { FileUtils.cd('..') }

      it 'displays an error and does not generate a new theme' do
        output = capture(:stdout) { subject.new('My Theme') }
        expect(output).to match /ERROR: Cannot create a new theme within the folder of another theme./
        expect(File).to_not exist "#{theme_root}/my_theme/assets/css/site.css"
      end
    end
  end # new

  describe 'validate' do
    describe 'all' do
      context 'with minimal valid theme' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        it 'checks all validations with blank TARGET' do
          output = capture(:stdout) { subject.validate }
          expect(output).to include 'Validating config...'
          expect(output).to include 'Validating theme...'
          expect(output).to include 'Validating layouts...'
          expect(output).to include 'Validating content templates...'
          expect(output).to include 'Validating navigation menus...'
          expect(output).to include 'Validating assets...'
        end

        it 'checks all validations with `all` TARGET' do
          output = capture(:stdout) { subject.validate('all') }
          expect(output).to include 'Validating config...'
          expect(output).to include 'Validating theme...'
          expect(output).to include 'Validating layouts...'
          expect(output).to include 'Validating content templates...'
          expect(output).to include 'Validating navigation menus...'
          expect(output).to include 'Validating assets...'
        end
      end

      context 'with `config.json.sample` warning' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        before do
          File.open(theme_root + '/config.json.sample', 'w') do |f|
            f.write JSON.generate({
              admin_domain: 'example.liveeditorapp.com'
            })
          end
        end

        it 'displays warning' do
          output = capture(:stdout) { subject.validate }
          expect(output).to include 'WARNING: It is not recommended to store `admin_domain` in the `/config.sample.json` file.'
        end
      end

      context 'with `content_templates/content_templates.json` error' do
        include_context 'minimal valid theme'
        include_context 'within theme root'
        include_context 'with content_templates folder'

        before do
          File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
            f.write 'bananas'
          end
        end

        it 'displays error' do
          output = capture(:stdout) { subject.validate }
          expect(output).to include 'ERROR: The file at `/content_templates/content_templates.json` does not contain valid JSON markup.'
        end
      end
    end # all

    describe 'layouts' do
      context 'with minimal valid theme' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        it 'checks just layouts with `layouts` target' do
          output = capture(:stdout) { subject.validate('layouts') }
          expect(output).to include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end

        it 'checks just layouts with `layout` target' do
          output = capture(:stdout) { subject.validate('layout') }
          expect(output).to include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end
      end
    end

    describe 'config' do
      context 'with `config.json.sample` warning' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        before do
          File.open(theme_root + '/config.json.sample', 'w') do |f|
            f.write JSON.generate({
              admin_domain: 'example.liveeditorapp.com'
            })
          end
        end

        it 'checks just config' do
          output = capture(:stdout) { subject.validate('config') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end

        it 'displays warning' do
          output = capture(:stdout) { subject.validate('config') }
          expect(output).to include 'WARNING: It is not recommended to store `admin_domain` in the `/config.sample.json` file.'
        end
      end
    end

    describe 'theme' do
      context 'with `config.json.sample` warning' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        it 'checks just theme' do
          output = capture(:stdout) { subject.validate('theme') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end
      end
    end

    describe 'content_templates' do
      context 'with `content_templates/content_templates.json` error' do
        include_context 'minimal valid theme'
        include_context 'within theme root'
        include_context 'with content_templates folder'

        before do
          File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
            f.write 'bananas'
          end
        end

        it 'checks just content templates with `content_templates` TARGET' do
          output = capture(:stdout) { subject.validate('content_templates') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end

        it 'checks just content templates with `content_template` TARGET' do
          output = capture(:stdout) { subject.validate('content_template') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end

        it 'displays error' do
          output = capture(:stdout) { subject.validate('content_templates') }
          expect(output).to include 'ERROR: The file at `/content_templates/content_templates.json` does not contain valid JSON markup.'
        end
      end # with `content_templates/content_templates.json` error
    end # content_templates

    describe 'navigation' do
      context 'with `config.json.sample` warning' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        it 'checks just navigation' do
          output = capture(:stdout) { subject.validate('navigation') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end
      end
    end

    describe 'assets' do
      context 'with `config.json.sample` warning' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        it 'checks just assets' do
          output = capture(:stdout) { subject.validate('assets') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to include 'Validating assets...'
        end
      end
    end

    context 'outside of theme folder' do
      it 'returns an error and does not generate any files' do
        output = capture(:stdout) { subject.validate }
        expect(output).to eql "ERROR: Must be within an existing Live Editor theme's folder to run this command."
      end
    end
  end # validate

  describe 'login' do
    context 'outside of theme root' do
      it 'displays an error' do
        output = capture(:stdout) { subject.login }
        expect(output).to eql "ERROR: Must be within an existing Live Editor theme's folder to run this command."
      end
    end

    context 'with no `config.json`' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'displays an error' do
        output = capture(:stdout) { subject.login }
        expect(output).to include 'ERROR: `/config.json` has not yet been created.'
      end
    end

    context 'with valid email and password' do
      include_context 'minimal valid theme'
      include_context 'within theme root'

      let(:output) { capture(:stdout) { subject.class.start(['login', '--email=user@example.com', '--password=n4ch0h4t']) } }

      it 'echoes options passed' do
        expect(output).to include 'Email: user@example.com'
        expect(output).to include 'Password: ********'
      end
    end
  end
end
