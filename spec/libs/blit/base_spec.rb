require File.join(File.dirname(__FILE__), "..", "..", 'spec_helper.rb')

class Pants < Blit::Base
  attributes :waist, :length
end

describe "a subclass of Blit::Base" do
  before(:all) do
    @path = Merb.root + "/repos/" + Merb.env + "/pants/"
    Dir.mkdir(@path)
  end

  before(:each) do
    @dir = stub("working directory", {
      :path => Merb.root + "/repos/" + Merb.env
    })
    @repos = stub("git repository", :dir => @dir, :add => nil, :commit => nil)
    @hk = stub("housekeeper", :increment => 1, :sync => nil, :out_of_sync? => false)
    Blit.stub!(:repository).and_return(@repos)
    Blit::HouseKeeper.stub!(:new).and_return(@hk)
    Pants.instance_variable_set("@housekeeper", nil)
  end

  it "should have a housekeeper" do
    Blit::HouseKeeper.should_receive(:new).with("#{Merb.root}/repos/test/pants").and_return(@hk)
    Pants.housekeeper.should == @hk
  end

  it "should have attribute accessors" do
    Pants.instance_methods.should include("waist")
    Pants.instance_methods.should include("length")
  end

  it "should have a full_path" do
    Pants.full_path.should == File.join(Merb.root, "repos", Merb.env, "pants")
  end

  it "should have a plural" do
    Pants.plural.should == "pants"
  end

  describe ".find" do
    before(:all) do
      File.open(@path + "123", 'w') do |f|
        f.puts({:waist => 36, :length => 32}.to_yaml)
      end
      File.open(@path + "456", 'w') do |f|
        f.puts({:waist => 38, :length => 30}.to_yaml)
      end
    end

    before(:each) do
      @repos.stub!(:ls_files).and_return({
        "pants/housekeeping" => {},
        "pants/123" => {},
        "pants/456" => {},
      })
    end

    describe "when finding a single object" do
      it "should return nil if file doesn't exist" do
        Pants.find(321).should be_nil
      end

      it "should instantiate the object if it is found" do
        pants = Pants.find(123)
        pants.waist.should == 36
        pants.length.should == 32
        pants.id.should == 123
      end
    end
    
    describe "when finding all objects" do
      it "should instantiate all objects" do
        p1, p2 = Pants.find(:all)
        p1.waist.should == 36
        p1.length.should == 32
        p1.id.should == 123
        p2.waist.should == 38
        p2.length.should == 30
        p2.id.should == 456
      end
    end

    after(:all) do
      File.delete(@path + "123")
      File.delete(@path + "456")
    end
  end

  describe "#instantiate" do
    before(:all) do
      File.open(@path + "123", 'w') do |f|
        f.puts({:waist => 36, :length => 32}.to_yaml)
      end
    end

    it "should allocate the object without initializing it" do
      pants = stub(Pants)
      Pants.should_receive(:allocate).and_return(pants)
      Pants.instantiate.should == pants
    end

    it "should load a file if an id is given" do
      pants = Pants.instantiate(123)
      pants.waist.should == 36
      pants.length.should == 32
    end

    it "should set the object's id if given" do
      pants = Pants.instantiate(123)
      pants.id.should == 123
    end

    after(:all) do
      File.delete(@path + "123")
    end
  end

  describe "#save" do
    describe "when saving an existing object" do
      before(:all) do
        File.open(@path + "123", 'w') do |f|
          f.puts({:waist => 36, :length => 32}.to_yaml)
        end
      end

      before(:each) do
        @pants = Pants.instantiate(123)
      end

      it "should not increment the housekeeper" do
        @hk.should_not_receive(:increment)
        @pants.save
      end

      it "should not sync the housekeeper" do
        @hk.should_not_receive(:sync)
        @pants.save
      end

      it "should not add the housekeeper file" do
        @repos.should_not_receive(:add).with("pants/housekeeping")
        @pants.save
      end
      
      after(:all) do
        File.delete(@path + "123")
      end
    end

    describe "when saving a new object" do
      before(:each) do
        @pants = Pants.new(:waist => 36, :length => 30)
        @hk.stub!(:out_of_sync?).and_return(true)
      end

      it "should create a file" do 
        @pants.save
        File.exist?(@path + "1").should be_true
      end

      it "should set id" do
        @pants.save
        @pants.id.should == 1
      end

      it "should create a file with the correct content" do
        @pants.save
        YAML.load_file(@path + "1").should == {
          :waist  => 36,
          :length => 30 
        }
      end

      it "should add it to the repository" do
        @repos.should_receive(:add).with("pants/1")
        @pants.save
      end

      it "should increment the housekeeper" do
        @hk.should_receive(:increment).and_return(1)
        @pants.save
      end

      it "should sync the housekeeper" do
        @hk.should_receive(:sync)
        @pants.save
      end

      it "should add the housekeeper file" do
        @repos.should_receive(:add).with("pants/housekeeping")
        @pants.save
      end

      it "should commit" do
        @repos.should_receive(:commit).with("Added pants 1")
        @pants.save
      end

      describe "when there are other files" do
        before(:each) do
          @hk.stub!(:increment).and_return(123)
        end

        it "should use the housekeeper's count for the filename" do
          @pants.save
          File.exist?(@path + "123").should be_true
        end

        it "should add it to the repository" do
          @repos.should_receive(:add).with("pants/123")
          @pants.save
        end

        it "should commit" do
          @repos.should_receive(:commit).with("Added pants 123")
          @pants.save
        end
      end

      after(:each) do
        File.delete(@path + "1")     if File.exist?(@path + "1")
        File.delete(@path + "123")   if File.exist?(@path + "123")
      end
    end
  end

  after(:all) do
    Dir.rmdir(@path)
  end
end
