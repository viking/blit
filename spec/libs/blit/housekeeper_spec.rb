require File.join(File.dirname(__FILE__), "..", "..", 'spec_helper.rb')
require 'ruby-debug'

describe Blit::HouseKeeper do
  @@path = Merb.root + "/repos/test/pants"
  before(:all) do
    Dir.mkdir(@@path)
  end

  before(:each) do
    @fn = File.join(@@path, "housekeeping")
    f   = File.new(@fn, 'w')
    f.puts({:count => 123}.to_yaml)
    f.close

    @hk = Blit::HouseKeeper.new(@@path)
  end

  it "should have a count" do
    @hk.count.should be_an_instance_of(Fixnum)
  end

  it "should read data from the housekeeping file" do
    @hk.count.should == 123
  end

  it "should have a filename" do
    @hk.filename.should == @fn
  end

  describe "#increment" do
    it "should add 1 to the count" do
      @hk.increment
      @hk.count.should == 124
    end

    it "should be out of sync after incrementing" do
      @hk.increment
      @hk.should be_out_of_sync
    end
  end

  describe "#out_of_sync?" do
    it "should be false" do
      @hk.should_not be_out_of_sync
    end
  end

  describe "#sync" do
    it "should write out to the housekeeping file" do
      @hk.increment
      @hk.sync
      YAML.load_file(@fn).should == {:count => 124}
    end

    it "should not be out of sync after syncing" do
      @hk.increment
      @hk.sync
      @hk.should_not be_out_of_sync
    end
  end

  after(:each) do
    File.delete(@fn)
  end

  after(:all) do
    Dir.rmdir(@@path)
  end
end
