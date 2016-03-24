require 'spec_helper'

RSpec.describe LiveEditor::CLI::Main do
  describe 'validate', fakefs: true do
    describe 'all' do
      context 'with minimal valid theme' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        it 'checks all validations with blank TARGET' do
          output = capture(:stdout) { subject.validate }
          expect(output).to include 'Validating config...'
          expect(output).to include 'Validating theme...'
          expect(output).to include 'Validating layouts...'
          expect(output).to include 'Validating content templates...'
          expect(output).to include 'Validating navigation menus...'
          expect(output).to include 'Validating assets...'
        end

        it 'checks all validations with `all` TARGET' do
          output = capture(:stdout) { subject.validate('all') }
          expect(output).to include 'Validating config...'
          expect(output).to include 'Validating theme...'
          expect(output).to include 'Validating layouts...'
          expect(output).to include 'Validating content templates...'
          expect(output).to include 'Validating navigation menus...'
          expect(output).to include 'Validating assets...'
        end
      end

      context 'with `config.json.sample` warning' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        before do
          File.open(theme_root + '/config.json.sample', 'w') do |f|
            f.write JSON.generate({
              admin_domain: 'example.liveeditorapp.com'
            })
          end
        end

        it 'displays warning' do
          output = capture(:stdout) { subject.validate }
          expect(output).to include 'WARNING: It is not recommended to store `admin_domain` in the `/config.sample.json` file.'
        end
      end

      context 'with `content_templates/content_templates.json` error' do
        include_context 'minimal valid theme'
        include_context 'within theme root'
        include_context 'with content_templates folder'

        before do
          File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
            f.write 'bananas'
          end
        end

        it 'displays error' do
          output = capture(:stdout) { subject.validate }
          expect(output).to include 'ERROR: The file at `/content_templates/content_templates.json` does not contain valid JSON markup.'
        end
      end
    end # all

    describe 'layouts' do
      context 'with minimal valid theme' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        it 'checks just layouts with `layouts` target' do
          output = capture(:stdout) { subject.validate('layouts') }
          expect(output).to include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end

        it 'checks just layouts with `layout` target' do
          output = capture(:stdout) { subject.validate('layout') }
          expect(output).to include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end
      end
    end

    describe 'config' do
      context 'with `config.json.sample` warning' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        before do
          File.open(theme_root + '/config.json.sample', 'w') do |f|
            f.write JSON.generate({
              admin_domain: 'example.liveeditorapp.com'
            })
          end
        end

        it 'checks just config' do
          output = capture(:stdout) { subject.validate('config') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end

        it 'displays warning' do
          output = capture(:stdout) { subject.validate('config') }
          expect(output).to include 'WARNING: It is not recommended to store `admin_domain` in the `/config.sample.json` file.'
        end
      end
    end

    describe 'theme' do
      context 'with `config.json.sample` warning' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        it 'checks just theme' do
          output = capture(:stdout) { subject.validate('theme') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end
      end
    end

    describe 'content_templates' do
      context 'with `content_templates/content_templates.json` error' do
        include_context 'minimal valid theme'
        include_context 'within theme root'
        include_context 'with content_templates folder'

        before do
          File.open(theme_root + '/content_templates/content_templates.json', 'w') do |f|
            f.write 'bananas'
          end
        end

        it 'checks just content templates with `content_templates` TARGET' do
          output = capture(:stdout) { subject.validate('content_templates') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end

        it 'checks just content templates with `content_template` TARGET' do
          output = capture(:stdout) { subject.validate('content_template') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end

        it 'displays error' do
          output = capture(:stdout) { subject.validate('content_templates') }
          expect(output).to include 'ERROR: The file at `/content_templates/content_templates.json` does not contain valid JSON markup.'
        end
      end # with `content_templates/content_templates.json` error
    end # content_templates

    describe 'navigation' do
      context 'with `config.json.sample` warning' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        it 'checks just navigation' do
          output = capture(:stdout) { subject.validate('navigation') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to include 'Validating navigation menus...'
          expect(output).to_not include 'Validating assets...'
        end
      end
    end

    describe 'assets' do
      context 'with `config.json.sample` warning' do
        include_context 'minimal valid theme'
        include_context 'within theme root'

        it 'checks just assets' do
          output = capture(:stdout) { subject.validate('assets') }
          expect(output).to_not include 'Validating layouts...'
          expect(output).to_not include 'Validating config...'
          expect(output).to_not include 'Validating theme...'
          expect(output).to_not include 'Validating content templates...'
          expect(output).to_not include 'Validating navigation menus...'
          expect(output).to include 'Validating assets...'
        end
      end
    end

    context 'outside of theme folder' do
      include_context 'outside of theme root'

      it 'returns an error and does not generate any files' do
        output = capture(:stdout) { subject.validate }
        expect(output).to eql "ERROR: Must be within an existing Live Editor theme's folder to run this command."
      end
    end
  end
end
