require 'sysmoon/ipc/data/file'

module Sysmoon
  class Handler
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
    end
  end
end
