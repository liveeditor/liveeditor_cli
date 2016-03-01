shared_context 'outside of theme root' do |fakefs = true|
  let(:temp_folder) do
    fakefs ? '/.live_editor' : Dir.home + '/./live_editor'
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

shared_context 'with layout Liquid template' do |filename|
  before do
    FileUtils.touch(theme_root + '/layouts/' + "#{filename}_layout.liquid")
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

shared_context 'minimal valid theme' do
  include_context 'basic theme'
  include_context 'with layouts folder'

  before do
    File.open(theme_root + '/config.json', 'w') do |f|
      f.write JSON.generate({
        admin_domain: 'example.liveeditorapp.com'
      })

      File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
        f.write JSON.generate({
          layouts: []
        })
      end
    end
  end
end

shared_context 'logged in' do
  before do
    admin_domain = JSON.parse(File.read(theme_root + '/config.json'))['admin_domain']
    LiveEditor::CLI::store_credentials(admin_domain, 'test@example.com', 'n4ch0h4t')
  end
end
