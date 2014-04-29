module Fallout
  class Backup
    def initialize(options)
      @volume = options[:volume]
      @keep = options[:keep]
    end

    def run 
      puts 'running backup' 
    end
  end
end