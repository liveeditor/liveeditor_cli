require 'pp' # https://github.com/fakefs/fakefs/issues/99
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.include(FakeFS::SpecHelpers, fakefs: true)
end
