shared_context 'outside of theme root' do |fakefs = true|
  let(:temp_folder) do
    fakefs ? '/.live_editor' : Dir.home + '/.live_editor'
  end

  before do
    Dir.mkdir(temp_folder)
    FileUtils.cd(temp_folder)
  end

  after do
    FileUtils.cd('/')
    FileUtils.rm_rf(temp_folder)
  end
end

shared_context 'basic theme' do |fakefs = true|
  let(:temp_folder) do
    fakefs ? '/.live_editor' : Dir.home + '/.live_editor'
  end

  let(:theme_root) do
    temp_folder + '/my_theme_' + (Time.now.to_f * 1000).to_i.to_s
  end

  before do
    Dir.mkdir(temp_folder)
    Dir.mkdir(theme_root)

    File.open(theme_root + '/theme.json', 'w+') do |f|
      f.write JSON.generate({ title: 'My Theme' })
    end
  end

  after do
    FileUtils.cd('/')
    FileUtils.rm_rf(temp_folder)
  end
end

shared_context 'within theme root' do
  before { FileUtils.cd(theme_root) }
end

shared_context 'with layouts folder' do
  before { Dir.mkdir(theme_root + '/layouts') }
end

shared_context 'with layout Liquid template' do |file_name|
  before do
    FileUtils.touch(theme_root + '/layouts/' + "#{file_name}_layout.liquid")
  end
end

shared_context 'with content_templates folder' do
  before { Dir.mkdir(theme_root + '/content_templates') }
end

shared_context 'with navigation folder' do
  before { Dir.mkdir(theme_root + '/navigation') }
end

shared_context 'with assets folder' do
  before { Dir.mkdir(theme_root + '/assets') }
end

shared_context 'with config.json' do
  before do
    File.open(theme_root + '/config.json', 'w') do |f|
      f.write JSON.generate({
        admin_domain: 'example.liveeditorapp.com'
      })
    end
  end
end

shared_context 'with layouts.json' do
  before do
    File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
      f.write JSON.generate({
        layouts: []
      })
    end
  end
end

shared_context 'minimal valid theme' do |fakefs = true|
  include_context 'basic theme', fakefs
  include_context 'with layouts folder'
  include_context 'with layouts.json'
  include_context 'with config.json'
end

shared_context 'logged in' do
  before do
    admin_domain = JSON.parse(File.read(theme_root + '/config.json'))['admin_domain']
    LiveEditor::CLI::store_credentials(admin_domain, 'test@example.com', '1234567890', '0987654321')
  end
end

shared_context 'with image asset' do
  before do
    Dir.mkdir(theme_root + '/assets')
    Dir.mkdir(theme_root + '/assets/images')

    File.open(theme_root + '/assets/images/logo.png', 'w') do |f|
      f.write '123456'
    end
  end
end

shared_context 'with partial' do
  before do
    Dir.mkdir(theme_root + '/partials')

    File.open(theme_root + '/partials/header.liquid', 'w') do |f|
      f.write <<-LIQUID
        <header class="header">
          {% navigation "global" %}
        </header>
      LIQUID
    end
  end
end

shared_context 'with content_templates.json' do
  before do
    Dir.mkdir(theme_root + '/content_templates')

    File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
      f.write({
        content_templates: []
      }.to_json)
    end
  end
end

shared_context 'with block' do
  before do
    json = File.read(theme_root + '/content_templates/content_templates.json')
    json = JSON.parse(json)

    json['content_templates'] << {
      title: 'Article',
      blocks: [
        {
          title: 'Title',
          data_type: 'text'
        }
      ]
    }

    File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
      f.write json.to_json
    end
  end
end

shared_context 'with display Liquid template' do
  before do
    json = File.read(theme_root + '/content_templates/content_templates.json')
    json = JSON.parse(json)

    json['content_templates'] << {
      title: 'Article',
      displays: [
        {
          title: 'Default',
          default: true
        }
      ]
    }

    File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
      f.write json.to_json
    end

    Dir.mkdir(theme_root + '/content_templates/article')

    content = <<-LIQUID
      <h1>{ 'title' | display_block }</h1>
    LIQUID

    File.open(theme_root + '/content_templates/article/default_display.liquid', 'w') do |f|
      f.write content.strip
    end
  end
end

shared_context 'with navigation.json' do
  before do
    File.open(theme_root + '/navigation/navigation.json', 'w') do |f|
      f.write JSON.generate({
        navigation: []
      })
    end
  end
end
