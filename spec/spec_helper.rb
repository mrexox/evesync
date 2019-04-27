require 'rspec/mocks/standalone'
require 'evesync/log'

RSpec.configure do |config|
  config.before(:all) do
    allow(Evesync::Log).to receive(:method_missing)
      .and_return(nil)
  end
end
