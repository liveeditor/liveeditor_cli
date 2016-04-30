require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::DisplayValidator, fakefs: true do
  context 'with minimum valid display' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with content_templates folder'

    let(:content_template_config) do
      {
        'title' => 'Article',
        'displays' => [
          { 'title' => 'Default' }
        ]
      }
    end

    let(:display_config) do
      {
        'title' => 'Default',
        'description' => 'A description.',
        'default' => true,
        'file_name' => 'the_default'
      }
    end

    let(:validator) do
      LiveEditor::CLI::Validators::DisplayValidator.new display_config, 0, 0, content_template_config,
                                                        "#{theme_root}/content_templates"
    end

    before do
      Dir.mkdir(theme_root + '/content_templates/article')
      FileUtils.touch(theme_root + '/content_templates/article/the_default_display.liquid')
    end

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'has no #messages' do
      validator.valid?
      expect(validator.messages).to eql []
    end

    it 'has no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end

    it 'has a no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with minimum valid display

  context 'with fully-loaded valid display' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with content_templates folder'

    let(:content_template_config) do
      {
        'title' => 'Article',
        'displays' => [
          { 'title' => 'Default' }
        ]
      }
    end

    let(:display_config) { { 'title' => 'Default' } }

    let(:validator) do
      LiveEditor::CLI::Validators::DisplayValidator.new display_config, 0, 0, content_template_config,
                                                        "#{theme_root}/content_templates"
    end

    before do
      Dir.mkdir(theme_root + '/content_templates/article')
      FileUtils.touch(theme_root + '/content_templates/article/default_display.liquid')
    end

    it 'is #valid?' do
      expect(validator.valid?).to eql true
    end

    it 'has no #messages' do
      validator.valid?
      expect(validator.messages).to eql []
    end

    it 'has no #errors' do
      validator.valid?
      expect(validator.errors).to eql []
    end

    it 'has a no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with fully-loaded valid display

  context 'with no matching Liquid template' do
    include_context 'basic theme'
    include_context 'within theme root'
    include_context 'with content_templates folder'

    let(:content_template_config) do
      {
        'title' => 'Article',
        'displays' => [
          { 'title' => 'Default' }
        ]
      }
    end

    let(:display_config) { { 'title' => 'Default' } }

    let(:validator) do
      LiveEditor::CLI::Validators::DisplayValidator.new display_config, 0, 0, content_template_config,
                                                        "#{theme_root}/content_templates"
    end

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end
    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's display in position 1 within the file at `/content_templates/content_templates.json` is missing its matching Liquid template at `/content_templates/article/default_display.liquid`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's display in position 1 within the file at `/content_templates/content_templates.json` is missing its matching Liquid template at `/content_templates/article/default_display.liquid`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with display and no matching Liquid template

  context 'with non-boolean `default`' do
    include_context 'basic theme'
    include_context 'with content_templates folder'
    include_context 'within theme root'

    let(:content_template_config) do
      {
        'title' => 'Article',
        'displays' => [
          { 'title' => 'Default' }
        ]
      }
    end

    let(:display_config) { { 'title' => 'Default', 'default' => 'banana' } }

    let(:validator) do
      LiveEditor::CLI::Validators::DisplayValidator.new display_config, 0, 0, content_template_config,
                                                        "#{theme_root}/content_templates"
    end

    before do
      Dir.mkdir(theme_root + '/content_templates/article')
      FileUtils.touch(theme_root + '/content_templates/article/default_display.liquid')
    end

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's display in position 1 within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `default`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's display in position 1 within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `default`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with non-boolean display `default`
end
