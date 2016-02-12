shared_context 'basic theme' do
  let(:theme_root) do
    folder = 'my_theme_' + (Time.now.to_f * 1000).to_i.to_s
    File.dirname(File.realpath(__FILE__)).sub('support', folder)
  end

  before do
    Dir.mkdir(theme_root)

    File.open(theme_root + '/theme.json', 'w+') do |f|
      f.write JSON.generate({
        title: 'My Theme'
      })
    end
  end

  after do
    FileUtils.rm_rf(theme_root)
  end
end

shared_context 'within theme root' do
  before { FileUtils.cd(theme_root) }
  after { FileUtils.cd('..') }
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
