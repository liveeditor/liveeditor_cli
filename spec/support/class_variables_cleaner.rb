RSpec.configure do |config|
  config.before do
    if LiveEditor::CLI::class_variable_defined?(:@@config_config)
      LiveEditor::CLI::remove_class_variable :@@config_config
    end

    if LiveEditor::CLI::class_variable_defined?(:@@content_templates_config)
      LiveEditor::CLI::remove_class_variable :@@content_templates_config
    end

    if LiveEditor::CLI::class_variable_defined?(:@@layouts_config)
      LiveEditor::CLI::remove_class_variable :@@layouts_config
    end

    if LiveEditor::CLI::class_variable_defined?(:@@navigation_config)
      LiveEditor::CLI::remove_class_variable :@@navigation_config
    end

    if LiveEditor::CLI::class_variable_defined?(:@@theme_config)
      LiveEditor::CLI::remove_class_variable :@@theme_config
    end

    if LiveEditor::CLI::class_variable_defined?(:@@theme_root_dir)
      LiveEditor::CLI::remove_class_variable :@@theme_root_dir
    end
  end
end
