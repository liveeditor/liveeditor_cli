RSpec.configure do |config|
  config.before do
    if LiveEditor::CLI::class_variable_defined?(:@@content_templates_config)
      LiveEditor::CLI::remove_class_variable :@@content_templates_config
    end

    if LiveEditor::CLI::class_variable_defined?(:@@theme_root_dir)
      LiveEditor::CLI::remove_class_variable :@@theme_root_dir
    end
  end
end
