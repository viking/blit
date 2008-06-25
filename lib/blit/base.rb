module Blit
  class Base
    class << self
      def attributes(*names)
        names.each do |name| 
          class_eval <<-EOF, __FILE__, __LINE__
            def #{name}
              @attributes[:#{name}]
            end
          EOF
        end
      end

      def full_path
        @full_path ||= File.join(Blit.repository.dir.path, plural)
      end

      def plural
        @plural ||= name.downcase.pluralize
      end

      def housekeeper
        @housekeeper ||= HouseKeeper.new(full_path)
      end
      
      def instantiate(id = nil)
        obj = allocate
        if id
          attribs = YAML.load_file(File.join(full_path, id.to_s))
          obj.instance_variable_set("@attributes", attribs)
          obj.instance_variable_set("@id", id)
        end
        obj
      end

      def find(arg)
        ids = Blit.repository.ls_files.keys.select do |k|
          k =~ /^#{plural}\/\d+/
        end
        ids.collect! { |k| k.sub(/^.+?(\d+)$/, '\1').to_i }

        case arg
        when Fixnum
          return nil  unless ids.include?(arg)
          instantiate(arg)
        when :all
          ids.collect { |i| instantiate(i) } 
        end
      end
    end

    attr_reader :id
    
    def initialize(attribs = {})
      @attributes = attribs
      @id = nil
    end

    def save
      # create file
      @id ||= housekeeper.increment
      fn = File.join(self.class.full_path, @id.to_s)
      f  = File.new(fn, "w")
      f.puts @attributes.to_yaml
      f.close

      # add and commit
      if housekeeper.out_of_sync?
        housekeeper.sync  
        Blit.repository.add("#{self.class.plural}/housekeeping")
      end
      Blit.repository.add("#{self.class.plural}/#{id}")
      Blit.repository.commit("Added #{self.class.name.downcase} #{id}")
    end

    def housekeeper
      self.class.housekeeper
    end
  end
end
