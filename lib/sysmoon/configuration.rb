require 'inifile'
require 'sysmoon/constants'

module Sysmoon
  module Configuration
    Data = IniFile.load(Constants::CONFIG_FILE)
  end
end
