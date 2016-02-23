require 'spec_helper'

RSpec.describe LiveEditor::CLI, fakefs: true do
  shared_examples 'theme_root_dir' do |method, sends_output|
    context 'outside of any theme folders' do
      include_context 'outside of theme root'

      it 'returns nil' do
        # No worries: the expect still runs properly when inside of the
        # `capture` block.
        capture(:stdout) { expect(LiveEditor::CLI::send(method)).to be_nil }
      end

      if sends_output
        it 'displays an error message' do
          output = capture(:stdout) { LiveEditor::CLI::send(method) }
          expect(output).to eql "ERROR: Must be within an existing Live Editor theme's folder to run this command."
        end
      end
    end

    context 'within theme root folder' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'returns the current folder' do
        expect(LiveEditor::CLI::send(method)).to eql theme_root
      end

      context 'within subfolder underneath theme root' do
        before do
          subfolder = theme_root + '/layouts'
          Dir.mkdir(subfolder)
          FileUtils.cd(subfolder)
        end

        it 'returns the root folder' do
          expect(LiveEditor::CLI::send(method)).to eql theme_root
        end
      end
    end
  end

  describe '.theme_root_dir' do
    it_behaves_like('theme_root_dir', :theme_root_dir, false)
  end

  describe '.theme_root_dir!' do
    it_behaves_like('theme_root_dir', :theme_root_dir!, true)
  end

  describe '.naming_for' do
    describe :title do
      it 'titleizes a lowercase single word' do
        expect(LiveEditor::CLI::naming_for('staff')[:title]).to eql 'Staff'
      end

      it 'echoes a titleized single word' do
        expect(LiveEditor::CLI::naming_for('Staff')[:title]).to eql 'Staff'
      end

      it 'echoes a titleized phrase' do
        expect(LiveEditor::CLI::naming_for('Content Template')[:title]).to eql 'Content Template'
      end

      it 'titleizes an underscored phrase' do
        expect(LiveEditor::CLI::naming_for('content_template')[:title]).to eql 'Content Template'
      end

      it 'titleizes a lowercase phrase' do
        expect(LiveEditor::CLI::naming_for('content template')[:title]).to eql 'Content Template'
      end
    end

    describe :var_name do
      it 'echoes a lowercase single word' do
        expect(LiveEditor::CLI::naming_for('staff')[:var_name]).to eql 'staff'
      end

      it 'lowercases a titleized single word' do
        expect(LiveEditor::CLI::naming_for('Staff')[:var_name]).to eql 'staff'
      end

      it 'underscores a titleized phrase' do
        expect(LiveEditor::CLI::naming_for('Content Template')[:var_name]).to eql 'content_template'
      end

      it 'echoes an underscored phrase' do
        expect(LiveEditor::CLI::naming_for('content_template')[:var_name]).to eql 'content_template'
      end

      it 'underscores a lowercase phrase' do
        expect(LiveEditor::CLI::naming_for('content template')[:var_name]).to eql 'content_template'
      end
    end
  end
end
