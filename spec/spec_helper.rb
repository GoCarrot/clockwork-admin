require 'rack/test'
require 'zk'
require 'clockwork/admin'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
