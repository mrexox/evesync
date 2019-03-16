require 'sysmoon/ipc/data/file'

module Sysmoon
  module Handler
    class File
      def handle(file)
        # TODO: handle file creation, updating, deletion, moving and so on
        Log.debug("#{self.class.name} handling")
        content = file.content
        name = file.name
        Log.debug("Writing #{content} to #{name}")
        ::File.write(name, content)
        'Fine'
      end

      def ignore(file)
        Log.debug("Yuuuuaaa ignoring #{file}")
      end

      def unignore(file)
        Log.debug("Oooooyeeee unignoring #{file}")
        'Oops'
      end
    end
  end
end
