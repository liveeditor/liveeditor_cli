require 'spec_helper'

RSpec.describe LiveEditor::CLI::Main do
  describe 'login', fakefs: true do
    context 'outside of theme root' do
      include_context 'outside of theme root'

      it 'displays an error' do
        output = capture(:stdout) { subject.login }
        expect(output).to eql "ERROR: Must be within an existing Live Editor theme's folder to run this command."
      end
    end

    context 'with no `config.json`' do
      include_context 'basic theme'
      include_context 'within theme root'

      it 'displays an error' do
        output = capture(:stdout) { subject.login }
        expect(output).to include 'ERROR: `/config.json` has not yet been created.'
      end
    end

    context 'with valid email and password' do
      include_context 'minimal valid theme'
      include_context 'within theme root'

      before do
        stub_request(:post, 'example.api.liveeditorapp.com/oauth/token.json')
          .to_return(status: 200, body: JSON.generate({ refresh_token: '1234567890' }))
      end

      it 'echoes options passed and displays a success message' do
        output = capture(:stdout) { subject.class.start(['login', '--email=user@example.com', '--password=n4ch0h4t']) }
        expect(output).to include 'Email: user@example.com'
        expect(output).to include 'Password: ********'
        expect(output).to include 'You are now logged in to the admin at `example.liveeditorapp.com`.'
      end
    end

    context 'with invalid email and password' do
      include_context 'minimal valid theme'
      include_context 'within theme root'

      before do
        stub_request(:post, 'example.api.liveeditorapp.com/oauth/token.json')
          .to_return(status: 401, body: JSON.generate({ error: 'Invalid email or password.' }))
      end

      it 'echoes options passed and displays an error message' do
        output = capture(:stdout) { subject.class.start(['login', '--email=user@example.com', '--password=n4ch0h4t']) }
        expect(output).to include 'Email: user@example.com'
        expect(output).to include 'Password: ********'
        expect(output).to include 'ERROR: Invalid email or password.'
      end
    end
  end
end
