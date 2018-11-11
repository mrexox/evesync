#!/usr/bin/env ruby
require 'test/unit'
require 'fileutils'
require_relative "inotify"

class TestAddRmWatch < Test::Unit::TestCase
  def setup
    @a = Inotify.new
  end

  def test_rm_add_watch
    # Asserting we don't get any errors on method calls
    assert_nothing_raised { @a.add_watch('/etc/test1', Inotify::IN_ALL_EVENTS) }
    assert_nothing_raised { @a.add_watch('/etc/environment', Inotify::IN_ALL_EVENTS) }
    assert_nothing_raised { @a.add_watch('/etc/exports', Inotify::IN_ALL_EVENTS) }
    assert_nothing_raised { @a.rm_watch('/etc/test1') }
    assert_nothing_raised { @a.rm_watch('/etc/environment') }
    assert_nothing_raised { @a.rm_watch('/etc/exports') }
  end
end

class TestLoop < Test::Unit::TestCase
  def setup
    @a = Inotify.new
    FileUtils.touch('/tmp/testSimpleFile_')
    @a.add_watch('/tmp/testSimpleFile_', Inotify::IN_ALL_EVENTS)
  end

  def test_loop
    assert_nothing_raised do
      @a.run do
        break
      end
    end
  end
end
