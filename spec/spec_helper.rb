require 'rspec/mocks/standalone'
require 'evesync/log'

RSpec.configure do |config|
  config.before(:all) do
    Evesync::Log::LEVELS.each do |level|
      allow(Evesync::Log).to receive(level)
                               .and_return(nil)
    end
  end
end

# codecov coverage report
require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov
