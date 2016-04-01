require 'spec_helper'

RSpec.describe LiveEditor::CLI::Main do
  context 'within valid theme' do
    include_context 'basic theme', false
    include_context 'within theme root'

    before do
      Dir.mkdir(theme_root + '/navigation')

      File.open(theme_root + '/navigation/navigation.json', 'w+') do |f|
        nav_config = { navigation: [] }
        f.write(JSON.generate(nav_config))
      end
    end

    context 'with titleized TITLE' do
      it "echoes new navigation menu's TITLE" do
        output = capture(:stdout) { subject.generate('navigation', 'My Nav') }
        expect(output).to match /Creating a new navigation menu titled "My Nav".../
      end

      it 'adds the new menu entry into navigation.json' do
        output = capture(:stdout) { subject.generate('navigation', 'My Nav') }
        nav_config = JSON.parse(File.read(theme_root + '/navigation/navigation.json'))

        expect(nav_config['navigation'].first['title']).to eql 'My Nav'
        expect(nav_config['navigation'].first['var_name']).to eql 'my_nav'
        expect(nav_config['navigation'].first['description']).to eql ''
      end

      it 'creates a new my_nav_navigation.liquid file' do
        output = capture(:stdout) { subject.generate('navigation', 'My Nav') }
        expect(File).to exist(theme_root + '/navigation/my_nav_navigation.liquid')
      end
    end

    context 'with underscored TITLE' do
      it "echoes new menu's TITLE" do
        output = capture(:stdout) { subject.generate('navigation', 'my_nav') }
        expect(output).to match /Creating a new navigation menu titled "My Nav".../
      end

      it 'adds the new menu entry into navigation.json' do
        output = capture(:stdout) { subject.generate('navigation', 'my_nav') }
        nav_config = JSON.parse(File.read(theme_root + '/navigation/navigation.json'))

        expect(nav_config['navigation'].first['title']).to eql 'My Nav'
        expect(nav_config['navigation'].first['var_name']).to eql 'my_nav'
        expect(nav_config['navigation'].first['description']).to eql ''
      end

      it 'creates a new my_nav_navigation.liquid file' do
        output = capture(:stdout) { subject.generate('navigation', 'my_nav') }
        expect(File).to exist(theme_root + '/navigation/my_nav_navigation.liquid')
      end
    end
  end # within valid theme

  context 'outside of theme folder' do
    include_context 'outside of theme root', false

    it 'returns an error and does not generate any files' do
      output = capture(:stdout) { subject.generate('navigation', 'my_nav') }
      expect(output).to eql "ERROR: Must be within an existing Live Editor theme's folder to run this command."
      expect(File).to_not exist(FileUtils.pwd + '/navigation/my_nav_navigation.liquid')
    end
  end
end
