require 'spec_helper'

RSpec.describe LiveEditor::Cli do
  describe :theme_root_dir do
    context 'outside of any theme folders' do
      it 'returns nil' do
        expect(LiveEditor::Cli::theme_root_dir).to be_nil
      end
    end

    context 'within theme root folder' do
      include_context 'basic theme'
      before { FileUtils.cd(theme_root) }
      after { FileUtils.cd('..') }

      it 'returns the current folder' do
        expect(LiveEditor::Cli::theme_root_dir).to eql theme_root
      end

      context 'within subfolder underneath theme root' do
        before do
          subfolder = theme_root + '/layouts'
          Dir.mkdir(subfolder)
          FileUtils.cd(subfolder)
        end

        after { FileUtils.cd('..') }

        it 'returns the root folder' do
          expect(LiveEditor::Cli::theme_root_dir).to eql theme_root
        end
      end
    end
  end

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
