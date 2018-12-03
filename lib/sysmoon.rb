# :markup: TomDoc
require 'sysmoon/watcher'

# Public: All system monitoring methods go here.
#   See Examples for more.
#
# Examples
#
#   requrie 'sysmoon'
#   sysmoon = Sysmoon.new params
#   ...
#
class Sysmoon
  def initialize(params)
    @config = load_config(params[:config])
  end

  def add_watchers
  end

  def watch
  end

  private

  def load_config(conf_path)
  end
end
