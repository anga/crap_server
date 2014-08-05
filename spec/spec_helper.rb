require 'bundler/setup'
Bundler.setup

require 'crap_server' # and any other gems you need

RSpec.configure do |config|
end

class Dummy
  def self.method_missing(method, *args, &blk)
  end
end