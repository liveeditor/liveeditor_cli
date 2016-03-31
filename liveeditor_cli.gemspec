lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'live_editor/cli/version'

Gem::Specification.new do |gem|
  gem.name          = 'liveeditor_cli'
  gem.version       = LiveEditor::CLI::VERSION
  gem.authors       = ['Chris Peters']
  gem.email         = ['webmaster@liveeditorcms.com']
  gem.description   = 'Command line interface for building, previewing, and syncing your Live Editor theme.'
  gem.summary       = 'Spin up a development server to preview your Live Editor theme as you develop it. Push your theme files to your Live Editor account. Perform data migrations after changing the structure of your theme.'
  gem.homepage      = 'http://www.liveeditorcms.com/support/designers/themes/cli-reference/'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']
  gem.executables  << 'liveeditor'

  gem.add_dependency 'thor',            '~> 0.19.1'
  gem.add_dependency 'activesupport',   '~> 4.2.6'
  gem.add_dependency 'netrc',           '~> 0.11.0'
  gem.add_dependency 'multipart-post',  '~> 2.0.0'
  gem.add_dependency 'mime-types',      '~> 3.0'
  gem.add_dependency 'mimemagic',       '~> 0.3.1'
  gem.add_dependency 'cocaine',         '~> 0.5.8'
  gem.add_dependency 'net_http_ssl_fix'

  gem.add_development_dependency 'rake',    '~> 10.0.4'
  gem.add_development_dependency 'rspec',   '~> 3.4.0'
  gem.add_development_dependency 'fakefs',  '~> 0.8.0'
  gem.add_development_dependency 'webmock', '~> 1.24.0'
end
