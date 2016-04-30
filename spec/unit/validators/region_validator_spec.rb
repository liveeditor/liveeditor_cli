require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::RegionValidator do
  context 'with minimum valid region config' do
    let(:region_config) { { 'title' => 'My Region' } }
    let(:validator) { LiveEditor::CLI::Validators::RegionValidator.new(region_config, 0, 0, []) }

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
  end

  context 'with fully-loaded valid region config', fakefs: true do
    let(:content_templates_config) do
      config = LiveEditor::CLI::Config::ContentTemplatesConfig.new('/')

      config.config = {
        'content_templates' => [
          { 'title' => 'Article' }
        ]
      }
      config.parsed = true
      config
    end

    let(:region_config) do
      {
        'title' => 'My Region',
        'var_name' => 'region',
        'description' => 'A description.',
        'content_templates' => [
          'text',
          'article'
        ],
        'max_num_content' => 1
      }
    end

    let(:validator) { LiveEditor::CLI::Validators::RegionValidator.new(region_config, 0, 0, content_templates_config) }

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
  end

  context 'with missing region `title`' do
    let(:region_config) { {} }
    let(:validator) { LiveEditor::CLI::Validators::RegionValidator.new(region_config, 0, 0, []) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The layout in position 1's region in position 1 must have a `title`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The layout in position 1's region in position 1 must have a `title`."
    end

    it 'has a no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with missing region `title`

  context 'with empty region `title`' do
    let(:region_config) { { 'title' => '' } }
    let(:validator) { LiveEditor::CLI::Validators::RegionValidator.new(region_config, 0, 0, []) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The layout in position 1's region in position 1 must have a `title`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The layout in position 1's region in position 1 must have a `title`."
    end

    it 'has a no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with empty region `title`

  context 'with non-array region `content_templates`' do
    let(:region_config) { { 'title' => 'My Theme', 'content_templates' => 'banana' } }
    let(:validator) { LiveEditor::CLI::Validators::RegionValidator.new(region_config, 0, 0, []) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The layout in position 1's region in position 1 has an invalid `content_templates` attribute: must be an array."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The layout in position 1's region in position 1 has an invalid `content_templates` attribute: must be an array."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with non-array region `content_templates`

  context 'with non-matching region `content_templates` value', fakefs: true do
    # Mock out a `ContentTemplatesConfig` object.
    let(:content_templates_config) do
      config = LiveEditor::CLI::Config::ContentTemplatesConfig.new('/')

      config.config = {
        'content_templates' => [
          {
            'title' => 'Text',
            'var_name' => 'text'
          }
        ]
      }
      config.parsed = true
      config
    end

    let(:region_config) do
      {
        'title' => 'My Theme',
        'content_templates' => ['banana']
      }
    end

    let(:validator) { LiveEditor::CLI::Validators::RegionValidator.new(region_config, 0, 0, content_templates_config) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The layout in position 1's region in position 1 has an invalid `content_template`: `banana`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The layout in position 1's region in position 1 has an invalid `content_template`: `banana`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with non-matching region `content_templates` value

  context 'with non-integer region `max_num_content`' do
    let(:region_config) { { 'title' => 'My Theme', 'max_num_content' => 'banana' } }
    let(:validator) { LiveEditor::CLI::Validators::RegionValidator.new(region_config, 0, 0, []) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The layout in position 1's region in position 1 has an invalid `max_num_content` attribute: must be an integer."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The layout in position 1's region in position 1 has an invalid `max_num_content` attribute: must be an integer."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end # with non-integer region `max_num_content`
end
