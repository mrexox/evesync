require 'rspec/mocks/standalone'
require 'sysmoon/log'

RSpec.configure do |config|
  config.before(:all) do
    allow(Sysmoon::Log).to receive(:method_missing)
                             .and_return(nil)
  end
end
