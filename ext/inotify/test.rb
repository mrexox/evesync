#!/usr/bin/env ruby
require 'test/unit'
require 'fileutils'
require 'inotify/inotify'

# Simple tests, no high load. Functionality only

class TestAddRmWatch < Test::Unit::TestCase
  def setup
    @a = Inotify.new
  end

  def test_rm_add_watch
    # Asserting we don't get any errors on method calls
    assert_nothing_raised {
      @a.add_watch('/etc/passwd', Inotify::IN_ALL_EVENTS)
    }
    assert_nothing_raised {
      @a.add_watch('/etc/environment', Inotify::IN_ALL_EVENTS)
    }
    assert_nothing_raised {
      @a.rm_watch('/etc/passwd')
    }
    assert_nothing_raised {
      @a.rm_watch('/etc/environment')
    }
  end

  def test_exceptions
    assert_raise(RuntimeError) {
      @a.add_watch('/aassa/asdsad', Inotify::IN_ALL_EVENTS)
    }
    assert_raise(RuntimeError) {
      @a.rm_watch('/aassa/asdsad')
    }
  end
end

class TestLoop < Test::Unit::TestCase
  def setup
    @a = Inotify.new
    @testfile = '/tmp/testSimpleFile_'
    FileUtils.touch(@testfile)
    @a.add_watch(@testfile, Inotify::IN_MODIFY)
  end

  def test_loop
    assert_nothing_raised do
      thr = Thread.new {
        sleep 0.01
        File.open(@testfile, 'w') { |file| file.write("test") }
      }

      # Starting thread
      thr.join
      @a.run do |mask, wd, name, cookie|
        puts("Got ivent! Mask: #{mask}, Wd: #{wd}, Name: #{name}, Cookie: #{cookie}")
        break
      end

    end
  end
end
