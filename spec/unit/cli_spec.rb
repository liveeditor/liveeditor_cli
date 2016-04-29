require 'spec_helper'

RSpec.describe LiveEditor::CLI, fakefs: true do
  shared_examples 'theme_root_dir' do |method, sends_output|
    context 'outside of any theme folders' do
      include_context 'outside of theme root'

      it 'returns nil' do
        # No worries: the expect still runs properly when inside of the
        # `capture` block.
        capture(:stdout) { expect(LiveEditor::CLI::send(method)).to be_nil }
      end

      if sends_output
        it 'displays an error message' do
          output = capture(:stdout) { LiveEditor::CLI::send(method) }
          expect(output).to eql "ERROR: Must be within an existing Live Editor theme's folder to run this command."
        end
      end
    end

    context 'within theme root folder' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'returns the current folder' do
        expect(LiveEditor::CLI::send(method)).to eql theme_root
      end

      context 'within subfolder underneath theme root' do
        before do
          subfolder = theme_root + '/layouts'
          Dir.mkdir(subfolder)
          FileUtils.cd(subfolder)
        end

        it 'returns the root folder' do
          expect(LiveEditor::CLI::send(method)).to eql theme_root
        end
      end
    end
  end

  describe '.theme_root_dir' do
    it_behaves_like('theme_root_dir', :theme_root_dir, false)
  end

  describe '.theme_root_dir!' do
    it_behaves_like('theme_root_dir', :theme_root_dir!, true)
  end

  describe '.display_server_errors_for' do
    let(:response) do
      error_response = Net::HTTPUnprocessableEntity.new('1.1', 422, '')
      error_response.add_field('Content-Type', 'application/vnd.api+json')
      error_response.instance_variable_set(:@body, {
        errors: [
          { detail: "can't be blank", source: { pointer: '/data/attributes/title' } }
        ]
      }.to_json)
      error_response.instance_variable_set(:@read, true)

      LiveEditor::API::Response.new(error_response)
    end

    context 'without prefix' do
      it 'displays the error' do
        output = capture(:stdout) { LiveEditor::CLI::display_server_errors_for(response) }
        expect(output).to eql "`title` can't be blank"
      end
    end

    context 'with prefix' do
      it 'displays the error' do
        output = capture(:stdout) { LiveEditor::CLI::display_server_errors_for(response, prefix: 'Some prefix:') }
        expect(output).to eql "Some prefix: `title` can't be blank"
      end
    end
  end

  describe '.naming_for' do
    describe :title do
      it 'titleizes a lowercase single word' do
        expect(LiveEditor::CLI::naming_for('staff')[:title]).to eql 'Staff'
      end

      it 'echoes a titleized single word' do
        expect(LiveEditor::CLI::naming_for('Staff')[:title]).to eql 'Staff'
      end

      it 'echoes a titleized phrase' do
        expect(LiveEditor::CLI::naming_for('Content Template')[:title]).to eql 'Content Template'
      end

      it 'titleizes an underscored phrase' do
        expect(LiveEditor::CLI::naming_for('content_template')[:title]).to eql 'Content Template'
      end

      it 'titleizes a lowercase phrase' do
        expect(LiveEditor::CLI::naming_for('content template')[:title]).to eql 'Content Template'
      end
    end

    describe :var_name do
      it 'echoes a lowercase single word' do
        expect(LiveEditor::CLI::naming_for('staff')[:var_name]).to eql 'staff'
      end

      it 'lowercases a titleized single word' do
        expect(LiveEditor::CLI::naming_for('Staff')[:var_name]).to eql 'staff'
      end

      it 'underscores a titleized phrase' do
        expect(LiveEditor::CLI::naming_for('Content Template')[:var_name]).to eql 'content_template'
      end

      it 'echoes an underscored phrase' do
        expect(LiveEditor::CLI::naming_for('content_template')[:var_name]).to eql 'content_template'
      end

      it 'underscores a lowercase phrase' do
        expect(LiveEditor::CLI::naming_for('content template')[:var_name]).to eql 'content_template'
      end
    end
  end

  describe '.request' do
    let!(:netrc_before) do
<<-NETRC
machine example.liveeditorapp.com
  login test@example.com
  password 1234567890|0987654321
NETRC
    end

    let(:client) do
      LiveEditor::API::Client.new domain: 'example.liveeditorapp.com', email: 'test@example.com',
                                  access_token: '1234567890', refresh_token: '0987654321'
    end

    let(:response) do
      LiveEditor::CLI::request do
        LiveEditor::API::Themes::Layout.create('Product', 'product_layout.liquid', '<html></html>')
      end
    end

    before do
      LiveEditor::API::client = client
      LiveEditor::CLI::store_credentials('example.liveeditorapp.com', 'test@example.com', '1234567890', '0987654321')
      File.chmod(0600, Netrc.default_path)
    end

    context 'with refreshed credentials' do
      let(:new_netrc) do
<<-NETRC
machine example.liveeditorapp.com
  login test@example.com
  password 0987654321|1234567890
NETRC
      end

      before do
        # First call to endpoint is unsuccessful.
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/layouts')
          .with(headers: { 'Authorization' => 'Bearer 1234567890' })
          .to_return(status: 401, headers: { 'Content-Type' => 'application/json' }, body: { error: 'Unauthorized request' }.to_json)

        # Auto-refresh of OAuth token when first try to an endpoint returns
        # unauthorized.
        stub_request(:post, 'http://example.api.liveeditorapp.com/oauth/token')
          .to_return(status: 200, body: { access_token: '0987654321', refresh_token: '1234567890' }.to_json)

        # Second call to endpoint is successful.
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/layouts')
          .with(headers: { 'Authorization' => 'Bearer 0987654321' })
          .to_return(status: 201, headers: { 'Content-Type' => 'application/vnd.api+json'}, body: { data: {} }.to_json)

        response
      end

      it 'changes the `.netrc` file' do
        expect(File.read(Netrc.default_path)).to eql new_netrc
      end
    end

    context 'without refreshed credentials' do
      before do
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/layouts')
          .to_return(status: 201, headers: { 'Content-Type' => 'application/vnd.api+json'}, body: { data: {} }.to_json)

        response
      end

      it 'does not change the `.netrc` file' do
        expect(File.read(Netrc.default_path)).to eql netrc_before
      end
    end
  end

  describe '.config_config' do
    context 'with valid `/config.json`' do
      include_context 'basic theme'
      include_context 'with config.json'
      include_context 'within theme root'

      it 'returns a `ConfigConfig` instance' do
        expect(LiveEditor::CLI::config_config).to be_a LiveEditor::CLI::Config::ConfigConfig
      end

      it 'has parsed the config' do
        expect(LiveEditor::CLI::config_config.parsed?).to eql true
      end
    end
  end

  describe '.content_templates_config' do
    context 'with valid `/content_templates/content_templates.json`' do
      include_context 'basic theme'
      include_context 'with content_templates.json'
      include_context 'within theme root'

      it 'returns a `ContentTemplatesConfig` instance' do
        expect(LiveEditor::CLI::content_templates_config).to be_a LiveEditor::CLI::Config::ContentTemplatesConfig
      end

      it 'has parsed the config' do
        expect(LiveEditor::CLI::content_templates_config.parsed?).to eql true
      end
    end
  end

  describe '.layouts_config' do
    context 'with valid `/layouts/layouts.json`' do
      include_context 'basic theme'
      include_context 'with layouts folder'
      include_context 'with layouts.json'
      include_context 'within theme root'

      it 'returns a `LayoutsConfig` instance' do
        expect(LiveEditor::CLI::layouts_config).to be_a LiveEditor::CLI::Config::LayoutsConfig
      end

      it 'has parsed the config' do
        expect(LiveEditor::CLI::layouts_config.parsed?).to eql true
      end
    end
  end

  describe '.navigation_config' do
    context 'with valid `/navigation/navigation.json`' do
      include_context 'basic theme'
      include_context 'with navigation folder'
      include_context 'with navigation.json'
      include_context 'within theme root'

      it 'returns a `NavigationConfig` instance' do
        expect(LiveEditor::CLI::navigation_config).to be_a LiveEditor::CLI::Config::NavigationConfig
      end

      it 'has parsed the config' do
        expect(LiveEditor::CLI::navigation_config.parsed?).to eql true
      end
    end
  end

  describe '.theme_config' do
    context 'with valid `/theme.json`' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'returns a `ThemeConfig` instance' do
        expect(LiveEditor::CLI::theme_config).to be_a LiveEditor::CLI::Config::ThemeConfig
      end

      it 'has parsed the config' do
        expect(LiveEditor::CLI::theme_config.parsed?).to eql true
      end
    end
  end
end
