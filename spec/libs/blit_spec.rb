require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Blit do
  describe ".repository" do
    it "should be a Git repository" do
      Blit.repository.should be_an_instance_of(Git::Base)
    end

    it "should have the correct working path" do
      Blit.repository.dir.path.should == File.join(Merb.root, "repos", Merb.env)
    end
  end
end
