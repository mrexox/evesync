require 'sysmoon/ipc/data/file'

module Sysmoon
  class Handler
    class File
      def handle(file)
        Log.debug("Handler File handling started...")
        content = file.content
        name = file.name
        Log.debug("Handler File writing received content to #{name}")

        if file.action == IPC::Data::File::Action::DELETE
          ::File.delete(name)
        else # TODO: handle move_to and move_from
          # TODO: handle exceptions or throw them
          # Writing content
          ::File.write(name, content)
          # Changing mode
          ::File.chmod(name, file.mode)
        end

        # Returning all fine!
        Log.debug("Handler File handling done!")
        true
      end
    end
  end
end
