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

      let(:response_payload) do
        {
          'data' => {
            'type' => 'layouts',
            'id' => '1234',
            'attributes' => {
              'title' => 'Site'
            }
          }
        }
      end

      it 'uploads the layout content' do
        stub_request(:post, "http://example.api.liveeditorapp.com/themes/layouts")
          .to_return(status: 201, body: response_payload.to_json, headers: { 'Content-Type' => 'application/vnd.json+api' } )

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading layouts...'
        expect(output).to include '/layouts/site_layout.liquid'
        expect(output).to_not include 'ERROR'
      end
    end # logged in with layout

    context 'logged in with layout and region' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with layout Liquid template', 'site'

      before do
        File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
          f.write JSON.generate({
            layouts: [
              {
                title: 'Site',
                regions: [
                  {
                    title: 'Main',
                    var_name: 'the-main'
                  }
                ]
              }
            ]
          })
        end
      end

      let(:response_payload) do
        {
          'data' => {
            'type' => 'layouts',
            'id' => '1234',
            'attributes' => {
              'title' => 'Site'
            },
            'relationships' => {
              'regions' => {
                'data' => [
                  {
                    'type' => 'regions',
                    'id' => '1235'
                  }
                ]
              }
            }
          },
          'included' => [
            {
              'type' => 'regions',
              'id' => '1235',
              'attributes' => {
                'title' => 'Main',
                'var-name' => 'the-main'
              }
            }
          ]
        }
      end

      it 'uploads the layout content' do
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/layouts')
          .to_return(status: 201, body: response_payload.to_json, headers: { 'Content-Type' => 'application/vnd.json+api' } )

        stub_request(:patch, 'http://example.api.liveeditorapp.com/themes/layouts/1234/regions/1235')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading layouts...'
        expect(output).to include '/layouts/site_layout.liquid'
        expect(output).to_not include 'ERROR'
      end
    end # logged in with layout and region

    context 'logged in with layout and region with validation error' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with layout Liquid template', 'site'

      before do
        File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
          f.write JSON.generate({
            layouts: [
              {
                title: 'Site',
                regions: [
                  {
                    title: 'Main',
                    var_name: 'the_main'
                  }
                ]
              }
            ]
          })
        end
      end

      let(:layout_response_payload) do
        {
          'data' => {
            'type' => 'layouts',
            'id' => '1234',
            'attributes' => {
              'title' => 'Site'
            },
            'relationships' => {
              'regions' => {
                'data' => [
                  {
                    'type' => 'regions',
                    'id' => '1235'
                  }
                ]
              }
            }
          },
          'included' => [
            {
              'type' => 'regions',
              'id' => '1235',
              'attributes' => {
                'title' => 'Main',
                'var-name' => 'the_main'
              }
            }
          ]
        }
      end

      let(:region_response_payload) do
        {
          'errors' => [
            {
              'detail' => 'has already been taken',
              'source' => {
                'pointer' => '/data/attributes/var-name'
              }
            }
          ]
        }
      end

      it 'aborts with an error' do
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/layouts')
          .to_return(status: 201, body: layout_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' } )

        stub_request(:patch, 'http://example.api.liveeditorapp.com/themes/layouts/1234/regions/1235')
          .to_return(status: 422, body: region_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading layouts...'
        expect(output).to include '/layouts/site_layout.liquid'
        expect(output).to include 'ERROR: Region `var_name` `the_main` has already been taken'
      end
    end # logged in with layout and region with validation error

    context 'logged in with content template and display' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with content_templates.json'
      include_context 'with display Liquid template', 'default'

      let(:content_template_response_payload) do
        {
          'data' => {
            'type' => 'content-templates',
            'id' => '1234',
            'attributes' => {
              'title' => 'Article'
            }
          }
        }
      end

      let (:display_response_payload) do
        {
          'data' => {
            'type' => 'displays',
            'id' => '1235',
            'attributes' => {
              'title' => 'Default',
              'default' => true,
              'content' => "<h1>{ 'title' | display_block }</h1>"
            }
          }
        }
      end

      it 'uploads the content template' do
        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/content-templates')
          .to_return(status: 201, body: content_template_response_payload.to_json, headers: { 'Content-Type' => 'application/vnd.json+api' } )

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes/content-templates/1234/displays')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading content templates...'
        expect(output).to include 'Article'
        expect(output).to include '/content_templates/article/default_display.liquid'
        expect(output).to_not include 'ERROR'
      end
    end # logged in with content template and display

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
