require 'spec_helper'

RSpec.describe LiveEditor::CLI::Main do
  describe 'push' do
    context 'logged in with image asset' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with image asset'

      it 'uploads the image asset' do
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/assets/signatures')
          .to_return(status: 200, body: { endpoint: 'https://s3.amazonaws.com/bucket' }.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, 'https://s3.amazonaws.com/bucket')
          .to_return(status: 200)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/assets/uploads')
          .to_return(status: 202)

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading assets...'
        expect(output).to include '/assets/images/logo.png'
        expect(output).to_not include 'ERROR'
      end
    end

    context 'logged in with partial' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with partial'

      it 'uploads the partial content' do
        stub_request(:post, "http://example.api.liveeditorapp.com/themes/partials")
          .to_return(status: 201)

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading partials...'
        expect(output).to include '/partials/header.liquid'
        expect(output).to_not include 'ERROR'
      end
    end

    context 'logged in with layout' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with layout Liquid template', 'site'

      before do
        File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
          f.write JSON.generate({
            layouts: [
              { title: 'Site' }
            ]
          })
        end
      end

      it 'uploads the layout content' do
        stub_request(:post, "http://example.api.liveeditorapp.com/layouts")
          .to_return(status: 201)

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading layouts...'
        expect(output).to include '/layouts/site_layout.liquid'
        expect(output).to_not include 'ERROR'
      end
    end

    context 'outside of theme root', fakefs: true do
      include_context 'outside of theme root'

      it 'displays an error' do
        output = capture(:stdout) { subject.push }
        expect(output).to eql "ERROR: Must be within an existing Live Editor theme's folder to run this command."
      end
    end

    context 'with no `config.json`', fakefs: true do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'displays an error', fakefs: true do
        output = capture(:stdout) { subject.push }
        expect(output).to include 'ERROR: `/config.json` has not yet been created.'
      end
    end

    context 'not logged in', fakefs: true do
      include_context 'minimal valid theme'
      include_context 'within theme root'

      it 'displays an error' do
        output = capture(:stdout) { subject.push }
        expect(output).to include 'ERROR: You must be logged in. Run the `liveeditor login` command to login.'
      end
    end
  end
end
