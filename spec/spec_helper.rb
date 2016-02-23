require 'fakefs/safe'
require 'webmock/rspec'
require 'live_editor/cli'

Dir["#{File.expand_path('../support', __FILE__)}/*.rb"].each do |file|
  require file
end
