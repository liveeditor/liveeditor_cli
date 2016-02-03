require 'spec_helper'

RSpec.describe LiveEditor::Cli do
  describe :naming_for do
    describe :title do
      it 'titleizes a lowercase single word' do
        expect(LiveEditor::Cli::naming_for('staff')[:title]).to eql 'Staff'
      end

      it 'echoes a titleized single word' do
        expect(LiveEditor::Cli::naming_for('Staff')[:title]).to eql 'Staff'
      end

      it 'echoes a titleized phrase' do
        expect(LiveEditor::Cli::naming_for('Content Template')[:title]).to eql 'Content Template'
      end

      it 'titleizes an underscored phrase' do
        expect(LiveEditor::Cli::naming_for('content_template')[:title]).to eql 'Content Template'
      end

      it 'titleizes a lowercase phrase' do
        expect(LiveEditor::Cli::naming_for('content template')[:title]).to eql 'Content Template'
      end
    end

    describe :var_name do
      it 'echoes a lowercase single word' do
        expect(LiveEditor::Cli::naming_for('staff')[:var_name]).to eql 'staff'
      end

      it 'lowercases a titleized single word' do
        expect(LiveEditor::Cli::naming_for('Staff')[:var_name]).to eql 'staff'
      end

      it 'underscores a titleized phrase' do
        expect(LiveEditor::Cli::naming_for('Content Template')[:var_name]).to eql 'content_template'
      end

      it 'echoes an underscored phrase' do
        expect(LiveEditor::Cli::naming_for('content_template')[:var_name]).to eql 'content_template'
      end

      it 'underscores a lowercase phrase' do
        expect(LiveEditor::Cli::naming_for('content template')[:var_name]).to eql 'content_template'
      end
    end
  end
end
