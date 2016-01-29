require 'spec_helper'

RSpec.describe LiveEditor::Cli::Main do
  describe 'version' do
    it 'returns the current version number' do
      output = capture(:stdout) { subject.version }
      expect(output).to eql "Live Editor CLI v#{LiveEditor::Cli::VERSION}"
    end
  end
end
