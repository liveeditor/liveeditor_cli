require 'spec_helper'

RSpec.describe LiveEditor::CLI::Main do
  let(:site_id)             { SecureRandom.uuid }
  let(:theme_id)            { SecureRandom.uuid }
  let(:content_template_id) { SecureRandom.uuid }
  let(:block_id)            { SecureRandom.uuid }
  let(:display_id)          { SecureRandom.uuid }
  let(:layout_id)           { SecureRandom.uuid }
  let(:region_id)           { SecureRandom.uuid }
  let(:navigation_id)       { SecureRandom.uuid }
  let(:theme_asset_id)      { SecureRandom.uuid }
  let(:asset_id)            { SecureRandom.uuid }
  let(:asset_upload_id)     { SecureRandom.uuid }
  let(:asset_image_id)      { SecureRandom.uuid }

  let(:site_response_payload) do
    {
      'data' => {
        'type' => 'sites',
        'id' => site_id,
        'attributes' => {
          'title' => 'Example Site',
          'subdomain-slug' => 'example'
        },
        'relationships' => {
          'theme' => {
            'data' => nil
          }
        }
      }
    }
  end

  let(:theme_response_payload) do
    {
      'data' => {
        'type' => 'themes',
        'id' => theme_id,
        'relationships' => {
          'theme-assets' => {
            'data' => []
          },
          'layouts' => {
            'data' => []
          },
          'content-templates' => {
            'data' => []
          },
          'navigations' => {
            'data' => []
          },
          'partials' => {
            'data' => []
          }
        }
      }
    }
  end

  describe 'push' do
    context 'logged in with new image asset' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with image asset'

      let(:upload_response) do
        {
          data: {
            type: 'asset-uploads',
            id: asset_upload_id,
            relationships: {
              asset: {
                data: {
                  type: 'assets',
                  id: asset_id
                }
              }
            }
          }
        }
      end

      it 'uploads the image asset' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/assets/signatures")
          .to_return(status: 200, body: { endpoint: 'https://s3.amazonaws.com/bucket' }.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, 'https://s3.amazonaws.com/bucket')
          .to_return(status: 200)

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/assets/uploads")
          .to_return(status: 202, body: upload_response.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:patch, "http://example.api.liveeditorapp.com/themes/#{theme_id}")
          .to_return(status: 200)

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to include ['Uploading assets...', "/assets/images/logo.png - uploading"].join("\n")
        expect(output).to include ['Publishing theme...', 'Published!'].join("\n")
      end
    end

    context 'logged in with existing unchanged image asset' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with image asset'

      before do
        site_response_payload['data']['relationships']['theme']['data'] = {
          'type' => 'themes',
          'id' => theme_id
        }

        theme_response_payload['data']['relationships']['theme-assets']['data'] << {
          'type' => 'theme-assets',
          'id' => theme_asset_id
        }

        theme_response_payload['included'] = [
          {
            'type' => 'theme-assets',
            'id' => theme_asset_id,
            'attributes' => {
              'path' => 'images/logo.png'
            },
            'relationships' => {
              'asset' => {
                'data' => {
                  'type' => 'assets',
                  'id' => asset_id
                }
              }
            }
          },
          {
            'type' => 'assets',
            'id' => asset_id,
            'attributes' => {
              'title' => nil,
              'content-type' => 'image/png',
              'type' => 'image',
              'subtype' => 'png'
            },
            'relationships' => {
              'asset' => {
                'data' => {
                  'type' => 'asset-images',
                  'id' => asset_image_id
                }
              }
            }
          },
          {
            'type' => 'asset-images',
            'id' => asset_image_id,
            'attributes' => {
              'file-name' => 'logo.png',
              'content-type' => 'image/png',
              'file-size' => 12345,
              'fingerprint' => 'e10adc3949ba59abbe56e057f20f883e'
            },
            'relationships' => {
              'asset' => {
                'data' => {
                  'type' => 'assets',
                  'id' => asset_id
                }
              }
            }
          }
        ]
      end

      it 'skips the image asset' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:get, "http://example.api.liveeditorapp.com/themes/#{theme_id}?include=theme-assets,theme-assets.asset,theme-assets.asset.asset,partials,navigations,layouts,layouts.regions,content-templates,content-templates.blocks,content-templates.displays")
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: theme_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/assets")
          .to_return(status: 201)

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to include ['Uploading assets...', '/assets/images/logo.png - already uploaded, skipping'].join("\n")
        expect(output).to include ['Publishing theme...', 'Published!'].join("\n")
      end
    end

    context 'logged in with existing changed image asset' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with image asset'

      before do
        site_response_payload['data']['relationships']['theme']['data'] = {
          'type' => 'themes',
          'id' => theme_id
        }

        theme_response_payload['data']['relationships']['theme-assets']['data'] << {
          'type' => 'theme-assets',
          'id' => theme_asset_id
        }

        theme_response_payload['included'] = [
          {
            'type' => 'theme-assets',
            'id' => theme_asset_id,
            'attributes' => {
              'path' => 'images/logo.png'
            },
            'relationships' => {
              'asset' => {
                'data' => {
                  'type' => 'assets',
                  'id' => asset_id
                }
              }
            }
          },
          {
            'type' => 'assets',
            'id' => asset_id,
            'attributes' => {
              'title' => nil,
              'content-type' => 'image/png',
              'type' => 'image',
              'subtype' => 'png'
            },
            'relationships' => {
              'asset' => {
                'data' => {
                  'type' => 'asset-images',
                  'id' => asset_image_id
                }
              }
            }
          },
          {
            'type' => 'asset-images',
            'id' => asset_image_id,
            'attributes' => {
              'file-name' => 'logo.png',
              'content-type' => 'image/png',
              'file-size' => 12345,
              'fingerprint' => 'different-than-local'
            },
            'relationships' => {
              'asset' => {
                'data' => {
                  'type' => 'assets',
                  'id' => asset_id
                }
              }
            }
          }
        ]
      end

      let(:upload_response) do
        {
          data: {
            type: 'asset-uploads',
            id: asset_upload_id,
            relationships: {
              asset: {
                data: {
                  type: 'assets',
                  id: asset_id
                }
              }
            }
          }
        }
      end

      it 'updates the image asset' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:get, "http://example.api.liveeditorapp.com/themes/#{theme_id}?include=theme-assets,theme-assets.asset,theme-assets.asset.asset,partials,navigations,layouts,layouts.regions,content-templates,content-templates.blocks,content-templates.displays")
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: theme_response_payload.to_json)

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/assets/signatures")
          .to_return(status: 200, body: { endpoint: 'https://s3.amazonaws.com/bucket' }.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, 'https://s3.amazonaws.com/bucket')
          .to_return(status: 200)

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/assets/uploads")
          .to_return(status: 202, body: upload_response.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:patch, "http://example.api.liveeditorapp.com/themes/#{theme_id}")
          .to_return(status: 200)

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to include ['Uploading assets...', '/assets/images/logo.png - uploading'].join("\n")
        expect(output).to include ['Publishing theme...', 'Published!'].join("\n")
      end
    end

    context 'logged in with removed image asset' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'

      before do
        site_response_payload['data']['relationships']['theme']['data'] = {
          'type' => 'themes',
          'id' => theme_id
        }

        theme_response_payload['data']['relationships']['theme-assets']['data'] << {
          'type' => 'theme-assets',
          'id' => theme_asset_id
        }

        theme_response_payload['included'] = [
          {
            'type' => 'theme-assets',
            'id' => theme_asset_id,
            'attributes' => {
              'path' => 'images/logo.png'
            },
            'relationships' => {
              'asset' => {
                'type' => 'assets',
                'id' => asset_id
              }
            }
          },
          {
            'type' => 'assets',
            'id' => asset_id,
            'attributes' => {
              'title' => nil,
              'content-type' => 'image/png',
              'type' => 'image',
              'subtype' => 'png'
            },
            'relationships' => {
              'asset' => {
                'data' => {
                  'type' => 'asset-images',
                  'id' => asset_image_id
                }
              }
            }
          },
          {
            'type' => 'asset-images',
            'id' => asset_image_id,
            'attributes' => {
              'file-name' => 'logo.png',
              'content-type' => 'image/png',
              'file-size' => 12345,
              'fingerprint' => 'different-than-local'
            },
            'relationships' => {
              'asset' => {
                'data' => {
                  'type' => 'assets',
                  'id' => asset_id
                }
              }
            }
          }
        ]
      end

      it 'does not upload or publish any assets' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:get, "http://example.api.liveeditorapp.com/themes/#{theme_id}?include=theme-assets,theme-assets.asset,theme-assets.asset.asset,partials,navigations,layouts,layouts.regions,content-templates,content-templates.blocks,content-templates.displays")
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: theme_response_payload.to_json)

        stub_request(:patch, "http://example.api.liveeditorapp.com/themes/#{theme_id}")
          .to_return(status: 200)

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to_not include 'Uploading assets...'
        expect(output).to include ['Publishing theme...', 'Published!'].join("\n")
      end
    end

    context 'logged in with partial' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with partial'

      it 'uploads the partial content' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/partials")
          .to_return(status: 201)

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading partials...'
        expect(output).to include '/partials/header.liquid'
        expect(output).to include 'Publishing theme...'
        expect(output).to include 'Published!'
      end
    end

    context 'logged in with partial and server error' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with partial'

      let(:error_payload) do
        {
          errors: [
            { detail: 'has already been taken', source: { pointer: '/data/attributes/file-name' } }
          ]
        }
      end

      it 'uploads the partial content' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/partials")
          .to_return(status: 422, body: error_payload.to_json, headers: { 'Content-Type' => 'application/vnd.api+json' })

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading partials...'
        expect(output).to include '/partials/header.liquid'
        expect(output).to include '`file_name` has already been taken'
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
            'id' => SecureRandom.uuid,
            'attributes' => {
              'title' => 'Site'
            }
          }
        }
      end

      it 'uploads the layout content' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/layouts")
          .to_return(status: 201, body: response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading layouts...'
        expect(output).to include '/layouts/site_layout.liquid'
        expect(output).to include 'Publishing theme...'
        expect(output).to include 'Published!'
      end
    end # logged in with layout

    context 'logged in with layout and server error' do
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

      let(:error_payload) do
        {
          errors: [
            { detail: 'has already been taken', source: { pointer: '/data/attributes/title' } }
          ]
        }
      end

      it 'aborts and displays server error' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/layouts")
          .to_return(status: 422, body: error_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Layout in position 1: `title` has already been taken'
      end
    end # logged in with layout and server error

    context 'logged in with layout and region' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with content_templates folder'
      include_context 'with layout Liquid template', 'site'

      before do
        # Content template is needed to match the one below.
        File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
          f.write JSON.generate({
            content_templates: [
              {
                title: 'Article'
              }
            ]
          })
        end

        File.open(theme_root + '/layouts/layouts.json', 'w') do |f|
          f.write JSON.generate({
            layouts: [
              {
                title: 'Site',
                regions: [
                  {
                    title: 'Main',
                    var_name: 'the-main',
                    content_templates: ['article']
                  }
                ]
              }
            ]
          })
        end
      end

      let(:ct_response_payload) do
        {
          'data' => {
            'type' => 'content-templates',
            'id' => content_template_id,
            'attributes' => {
              'title' => 'Article',
              'var-name' => 'article'
            }
          }
        }
      end

      let(:response_payload) do
        {
          'data' => {
            'type' => 'layouts',
            'id' => layout_id,
            'attributes' => {
              'title' => 'Site'
            },
            'relationships' => {
              'regions' => {
                'data' => [
                  {
                    'type' => 'regions',
                    'id' => region_id
                  }
                ]
              }
            }
          },
          'included' => [
            {
              'type' => 'regions',
              'id' => region_id,
              'attributes' => {
                'title' => 'Main',
                'var-name' => 'the-main'
              }
            }
          ]
        }
      end

      it 'uploads the layout content' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/content-templates")
          .to_return status: 201, body: ct_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' }

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/layouts")
          .to_return status: 201, body: response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' }

        stub_request(:patch, "http://example.api.liveeditorapp.com/themes/#{theme_id}/layouts/#{layout_id}/regions/#{region_id}")
          .to_return(status: 200)

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading layouts...'
        expect(output).to include '/layouts/site_layout.liquid'
        expect(output).to include 'Publishing theme...'
        expect(output).to include 'Published!'
      end
    end # logged in with layout and region

    context 'logged in with layout and region with server error' do
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
            'id' => layout_id,
            'attributes' => {
              'title' => 'Site'
            },
            'relationships' => {
              'regions' => {
                'data' => [
                  {
                    'type' => 'regions',
                    'id' => region_id
                  }
                ]
              }
            }
          },
          'included' => [
            {
              'type' => 'regions',
              'id' => region_id,
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

      before do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/layouts")
          .to_return status: 201, body: layout_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' }

        stub_request(:patch, "http://example.api.liveeditorapp.com/themes/#{theme_id}/layouts/#{layout_id}/regions/#{region_id}")
          .to_return status: 422, body: region_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' }
      end

      it 'aborts with an error' do
        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading layouts...'
        expect(output).to include '/layouts/site_layout.liquid'
        expect(output).to include 'Region `Main`: `var_name` has already been taken'
      end
    end # logged in with layout and region with server error

    context 'logged in with content template and server validation error' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with content_templates.json'
      include_context 'with block'

      let(:error_payload) do
        {
          errors: [
            { detail: "can't be blank", source: { pointer: '/data/attributes/title' } }
          ]
        }
      end

      before do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/content-templates")
          .to_return(status: 422, body: error_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      it 'displays the error' do
        output = capture(:stdout) { subject.push }
        expect(output).to include "`title` can't be blank"
      end
    end

    context 'logged in with content template and block' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with content_templates.json'
      include_context 'with block'

      let(:content_template_response_payload) do
        {
          'data' => {
            'type' => 'content-templates',
            'id' => content_template_id,
            'attributes' => {
              'title' => 'Article'
            }
          }
        }
      end

      let (:display_response_payload) do
        {
          'data' => {
            'type' => 'blocks',
            'id' => block_id,
            'attributes' => {
              'title' => 'Title',
              'data-type' => 'text',
              'var-name' => 'title'
            }
          }
        }
      end

      it 'uploads the content template' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/content-templates")
          .to_return(status: 201, body: content_template_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/content-templates/#{content_template_id}/blocks")
          .to_return(status: 200)

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading content templates...'
        expect(output).to include 'Article'
        expect(output).to include 'Publishing theme...'
        expect(output).to include 'Published!'
      end
    end # logged in with content template and block

    context 'logged in with content template, block, and server error' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with content_templates.json'
      include_context 'with block'

      let(:content_template_response_payload) do
        {
          'data' => {
            'type' => 'content-templates',
            'id' => content_template_id,
            'attributes' => {
              'title' => 'Article'
            }
          }
        }
      end

      let (:error_payload) do
        {
          errors: [
            { detail: 'has already been taken', source: { pointer: '/data/attributes/title' } }
          ]
        }
      end

      before do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/content-templates")
          .to_return(status: 201, body: content_template_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/content-templates/#{content_template_id}/blocks")
          .to_return(status: 422, body: error_payload.to_json, headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      it 'halts and displays error' do
        output = capture(:stdout) { subject.push }
        expect(output).to include 'Block in position 1: `title` has already been taken'
      end
    end # logged in with content template, block, and server error

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
            'id' => content_template_id,
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
            'id' => display_id,
            'attributes' => {
              'title' => 'Default',
              'default' => true,
              'content' => "<h1>{ 'title' | display_block }</h1>"
            }
          }
        }
      end

      it 'uploads the content template' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/content-templates")
          .to_return(status: 201, body: content_template_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/content-templates/#{content_template_id}/displays")
          .to_return(status: 200)

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 200)

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading content templates...'
        expect(output).to include 'Article'
        expect(output).to include '/content_templates/article/default_display.liquid'
        expect(output).to include 'Publishing theme...'
        expect(output).to include 'Published!'
      end
    end # logged in with content template and display

    context 'logged in with content template, display, and server error' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with content_templates.json'
      include_context 'with display Liquid template', 'default'

      let(:content_template_response_payload) do
        {
          'data' => {
            'type' => 'content-templates',
            'id' => content_template_id,
            'attributes' => {
              'title' => 'Article'
            }
          }
        }
      end

      let (:error_payload) do
        {
          errors: [
            { detail: 'has already been taken', source: { pointer: '/data/attributes/title' } }
          ]
        }
      end

      it 'uploads the content template' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/content-templates")
          .to_return(status: 201, body: content_template_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/content-templates/#{content_template_id}/displays")
          .to_return(status: 422, body: error_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Display in position 1: `title` has already been taken'
      end
    end # logged in with content template, display, and server error

    context 'logged in with navigation' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with navigation folder'
      include_context 'with navigation.json'
      include_context 'with navigation Liquid template'

      let(:content) do
<<-NAV
  <nav class="global-nav">
    {% for link in navigation.links %}
      <a href="{{ link.url }}" class="global-nav-link {% if link.active? %}is-active{% endif %}">
        {{ link.title }}
      </a>
    {% endfor %}
  </nav>
NAV
      end

      let(:request_payload) do
        {
          'data' => {
            'type' => 'navigations',
            'attributes' => {
              'title' => 'Global',
              'file-name' => 'global_navigation.liquid',
              'content' => content,
              'description' => nil,
              'var-name' => nil
            }
          }
        }
      end

      let(:response_payload) do
        {
          'data' => {
            'type' => 'navigations',
            'id' => navigation_id,
            'attributes' => {
              'title' => 'Global',
              'file-name' => 'global_navigation.liquid',
              'content' => content,
              'description' => nil,
              'var-name' => 'global'
            }
          }
        }
      end

      before do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/navigations")
          .with(body: request_payload.to_json)
          .to_return(status: 201, body: response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 200)
      end

      it 'uploads the navigation' do
        output = capture(:stdout) { subject.push }
        expect(output).to include 'Uploading navigation menus...'
        expect(output).to include 'Global'
        expect(output).to include 'Publishing theme...'
        expect(output).to include 'Published!'
      end
    end # logged in with navigation

    context 'logged in with navigation and server error' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'
      include_context 'with navigation folder'
      include_context 'with navigation.json'
      include_context 'with navigation Liquid template'

      let(:content) do
<<-NAV
  <nav class="global-nav">
    {% for link in navigation.links %}
      <a href="{{ link.url }}" class="global-nav-link {% if link.active? %}is-active{% endif %}">
        {{ link.title }}
      </a>
    {% endfor %}
  </nav>
NAV
      end

      let (:error_payload) do
        {
          errors: [
            { detail: 'has already been taken', source: { pointer: '/data/attributes/title' } }
          ]
        }
      end

      before do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:post, "http://example.api.liveeditorapp.com/themes/#{theme_id}/navigations")
          .to_return(status: 422, body: error_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      it 'uploads the navigation' do
        output = capture(:stdout) { subject.push }
        expect(output).to include '`title` has already been taken'
      end
    end # logged in with navigation and server error

    context 'logged in with site publish error' do
      include_context 'minimal valid theme', false
      include_context 'within theme root'
      include_context 'logged in'

      let (:error_payload) do
        {
          errors: [
            { detail: 'has already been taken', source: { pointer: '/data/attributes/subdomain-slug' } }
          ]
        }
      end

      it 'displays and error' do
        stub_request(:get, 'http://example.api.liveeditorapp.com/site')
          .to_return(headers: { 'Content-Type' => 'application/vnd.api+json' }, body: site_response_payload.to_json)

        stub_request(:post, 'http://example.api.liveeditorapp.com/themes')
          .to_return(status: 201, body: theme_response_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:patch, 'http://example.api.liveeditorapp.com/site')
          .to_return(status: 422, body: error_payload.to_json,
                     headers: { 'Content-Type' => 'application/vnd.api+json' })

        output = capture(:stdout) { subject.push }
        expect(output).to include 'Publishing theme...'
        expect(output).to include '`subdomain_slug` has already been taken'
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
