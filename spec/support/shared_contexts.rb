shared_context 'basic theme' do
  let(:theme_root) do
    folder = 'my_theme_' + (Time.now.to_f * 1000).to_i.to_s
    File.dirname(File.realpath(__FILE__)).sub('support', folder)
  end

  before do
    Dir.mkdir(theme_root)
    FileUtils.touch(theme_root + '/theme.json')
  end

  after do
    FileUtils.rm_rf(theme_root)
  end
end
