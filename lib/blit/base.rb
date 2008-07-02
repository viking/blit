module Blit
  class Base
    class << self
      def attributes(*names)
        names.each do |name| 
          class_eval <<-EOF, __FILE__, __LINE__
            def #{name}
              @attributes["#{name}"]
            end

            def #{name}=(val)
              @attributes["#{name}"] = val
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
        ids.collect! { |k| k.sub(/^.+?(\d+)$/, '\1').to_i }.sort!

        case arg
        when Fixnum, String 
          id = arg.to_i
          return nil  unless ids.include?(id)
          instantiate(id)
        when :all
          ids.collect { |i| instantiate(i) } 
        end
      end

      def callbacks
        @callbacks ||= { 
          :before_save => [],
          :before_create => []
        }
      end

      def before_save(*methods)
        callbacks[:before_save] += methods
      end

      def before_create(*methods)
        callbacks[:before_create] += methods
      end
    end

    attr_reader :id
    
    def initialize(attribs = {})
      @attributes = attribs
      @id = nil
    end

    def save
      # create file
      if @id.nil?
        @id = housekeeper.increment
        self.class.callbacks[:before_create].each { |method| self.send(method) }
      end
      self.class.callbacks[:before_save].each { |method| self.send(method) }
      write_attributes_to_file

      # add and commit
      if housekeeper.out_of_sync?
        housekeeper.sync  
        Blit.repository.add("#{self.class.plural}/housekeeping")
      end
      Blit.repository.add(shortfn)
      Blit.repository.commit("Added #{self.class.name.downcase} #{id}")
    end

    def update(attribs)
      before = @attributes.dup
      @attributes.merge!(attribs)
      self.class.callbacks[:before_save].each { |method| self.send(method) }

      if before != @attributes
        write_attributes_to_file

        Blit.repository.add(shortfn)
        Blit.repository.commit("Updated #{self.class.name.downcase} #{id}")
      end
    end

    def destroy
      File.delete(filename)
      Blit.repository.remove(shortfn)
      Blit.repository.commit("Removed #{self.class.name.downcase} #{id}")
    end

    def housekeeper
      self.class.housekeeper
    end

    def filename
      if @id
        @filename ||= File.join(self.class.full_path, @id.to_s)
      else
        nil
      end
    end

    def shortfn
      if @id
        @shortfn ||= File.join(self.class.plural, @id.to_s)
      else
        nil
      end
    end

    private
      def write_attributes_to_file
        File.open(filename, "w") do |f|
          f.puts @attributes.to_yaml
        end
      end
  end
end
