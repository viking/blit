module Blit
  class HouseKeeper
    attr_reader :filename
    def initialize(path)
      @filename = File.join(path, "housekeeping")
      @out_of_sync = false
      @info = YAML.load_file(@filename) || {}
      @info[:count] ||= 0
    end

    def count
      @info[:count]
    end

    def increment
      @out_of_sync = true
      @info[:count] += 1
    end

    def out_of_sync?
      @out_of_sync
    end

    def sync
      @out_of_sync = false
      File.open(@filename, 'w') do |f|
        f.puts @info.to_yaml 
      end
    end
  end
end
