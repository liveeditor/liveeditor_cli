require 'spec_helper'

RSpec.describe LiveEditor::CLI::Validators::BlockValidator do
  context 'with minimum valid config' do
    let(:block_config) { { 'title' => 'Title', 'data_type' => 'text' } }
    let(:validator) { LiveEditor::CLI::Validators::BlockValidator.new(block_config, 0, 0) }

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

  context 'with fully-loaded valid config' do
    let(:block_config) do
      {
        'title' => 'Title',
        'data_type' => 'text',
        'description' => 'A description.',
        'required' => true,
        'inline' => false,
        'var_name' => 'my_title'
      }
    end

    let(:validator) { LiveEditor::CLI::Validators::BlockValidator.new(block_config, 0, 0) }

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

  context 'with missing `title`' do
    let(:block_config) { { 'data_type' => 'text' } }
    let(:validator) { LiveEditor::CLI::Validators::BlockValidator.new(block_config, 0, 0) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with blank block `title` in `content_templates.json`' do
    let(:block_config) { { 'title' => '', 'data_type' => 'text' } }
    let(:validator) { LiveEditor::CLI::Validators::BlockValidator.new(block_config, 0, 0) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `title`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with missing block `data_type` in `content_templates.json`' do
    let(:block_config) { { 'title' => 'Title' } }
    let(:validator) { LiveEditor::CLI::Validators::BlockValidator.new(block_config, 0, 0) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `data_type`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `data_type`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with blank block `data_type` in `content_templates.json`' do
    let(:block_config) { { 'title' => 'Title', 'data_type' => '' } }
    let(:validator) { LiveEditor::CLI::Validators::BlockValidator.new(block_config, 0, 0) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `data_type`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid `data_type`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with non-boolean block `required` in `content_templates.json`' do
    let(:block_config) { { 'title' => 'Title', 'data_type' => 'text', 'required' => 'banana' } }
    let(:validator) { LiveEditor::CLI::Validators::BlockValidator.new(block_config, 0, 0) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `required`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `required`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end

  context 'with non-boolean block `inline` in `content_templates.json`' do
    let(:block_config) { { 'title' => 'Title', 'data_type' => 'text', 'inline' => 'banana' } }
    let(:validator) { LiveEditor::CLI::Validators::BlockValidator.new(block_config, 0, 0) }

    it 'is not #valid?' do
      expect(validator.valid?).to eql false
    end

    it 'has a #messages array with an error' do
      validator.valid?
      expect(validator.messages.first[:type]).to eql :error
    end

    it 'has a #messages array with an error message' do
      validator.valid?
      expect(validator.messages.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `inline`."
    end

    it 'has an #errors array with an error' do
      validator.valid?
      expect(validator.errors.first[:type]).to eql :error
    end

    it 'has an #errors array with an error message' do
      validator.valid?
      expect(validator.errors.first[:message]).to eql "The content template in position 1's block in position 1 within the file at `/content_templates/content_templates.json` does not have a valid boolean value for `inline`."
    end

    it 'has no #warnings' do
      validator.valid?
      expect(validator.warnings).to eql []
    end
  end
end
