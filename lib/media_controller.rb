module MediaController

  class Media
    def self.hi
      puts "Media"
    end
  end

end

require 'media_controller/media'
require 'media_controller/audio'
require 'media_controller/video'