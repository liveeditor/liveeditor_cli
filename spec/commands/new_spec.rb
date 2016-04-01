require 'spec_helper'

RSpec.describe LiveEditor::CLI::Main do
  describe 'new' do
    context 'with underscored TITLE' do
      include_context 'outside of theme root', false

      it "echoes new theme's TITLE" do
        output = capture(:stdout) { subject.new('my_theme') }
        expect(output).to match /Creating a new Live Editor theme titled "My Theme".../
      end

      it 'creates a `my_theme` folder with the correct contents' do
        output = capture(:stdout) { subject.new('my_theme') }

        # Check that correct files were generated.
        expect(File).to exist temp_folder + "/my_theme/assets/css/site.css"
        expect(File).to exist temp_folder + "/my_theme/assets/fonts/.keep"
        expect(File).to exist temp_folder + "/my_theme/assets/images/.keep"
        expect(File).to exist temp_folder + "/my_theme/assets/js/init.js"
        expect(File).to exist temp_folder + "/my_theme/assets/js/site.js"
        expect(File).to exist temp_folder + "/my_theme/content_templates/.keep"
        expect(File).to exist temp_folder + "/my_theme/partials/.keep"
        expect(File).to exist temp_folder + "/my_theme/layouts/layouts.json"
        expect(File).to exist temp_folder + "/my_theme/layouts/site_layout.liquid"
        expect(File).to exist temp_folder + "/my_theme/navigation/global_navigation.liquid"
        expect(File).to exist temp_folder + "/my_theme/navigation/navigation.json"
        expect(File).to exist temp_folder + "/my_theme/.gitignore"
        expect(File).to exist temp_folder + "/my_theme/config.json.sample"
        expect(File).to exist temp_folder + "/my_theme/README.md"
        expect(File).to exist temp_folder + "/my_theme/theme.json"

        # Check that template files were generated and parsed correctly.
        expect(IO.read(temp_folder + "/my_theme/README.md")).to match /^# My Theme/
        expect(IO.read(temp_folder + "/my_theme/theme.json")).to match /"title": "My Theme"/

        # Clean up generated my_theme directory.
        FileUtils.rm_rf(File.dirname(File.realpath(__FILE__)).sub('commands', 'my_theme'))
      end
    end # with underscored TITLE

    context 'with titleized TITLE' do
      include_context 'outside of theme root', false

      it "echoes new theme's name when titleized" do
        output = capture(:stdout) { subject.new('My Theme') }
        expect(output).to match /Creating a new Live Editor theme titled "My Theme".../
      end

      it 'creates a `my_theme` folder with the correct contents' do
        output = capture(:stdout) { subject.new('My Theme') }

        # Check that correct files were generated.
        expect(File).to exist temp_folder + "/my_theme/assets/css/site.css"
        expect(File).to exist temp_folder + "/my_theme/assets/fonts/.keep"
        expect(File).to exist temp_folder + "/my_theme/assets/images/.keep"
        expect(File).to exist temp_folder + "/my_theme/assets/js/init.js"
        expect(File).to exist temp_folder + "/my_theme/assets/js/site.js"
        expect(File).to exist temp_folder + "/my_theme/content_templates/.keep"
        expect(File).to exist temp_folder + "/my_theme/partials/.keep"
        expect(File).to exist temp_folder + "/my_theme/layouts/layouts.json"
        expect(File).to exist temp_folder + "/my_theme/layouts/site_layout.liquid"
        expect(File).to exist temp_folder + "/my_theme/navigation/global_navigation.liquid"
        expect(File).to exist temp_folder + "/my_theme/navigation/navigation.json"
        expect(File).to exist temp_folder + "/my_theme/.gitignore"
        expect(File).to exist temp_folder + "/my_theme/config.json.sample"
        expect(File).to exist temp_folder + "/my_theme/README.md"
        expect(File).to exist temp_folder + "/my_theme/theme.json"

        # Check that template files were generated and parsed correctly.
        expect(IO.read(temp_folder + "/my_theme/README.md")).to match /^# My Theme/
        expect(IO.read(temp_folder + "/my_theme/theme.json")).to match /"title": "My Theme"/
      end
    end # with titleized TITLE

    context 'within existing theme', fakefs: true do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'displays an error and does not generate a new theme' do
        output = capture(:stdout) { subject.new('My Theme') }
        expect(output).to match /ERROR: Cannot create a new theme within the folder of another theme./
        expect(File).to_not exist "#{theme_root}/my_theme/assets/css/site.css"
      end
    end
  end
end
