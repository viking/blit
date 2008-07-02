require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Post do

  it "should be a subclass of Blit::Base" do
    Post.superclass.should == Blit::Base
  end

  it "should have a title" do
    post = Post.new("title" => "pants")
    post.title.should == "pants"
  end

  it "should have a body" do
    post = Post.new("body" => "pants")
    post.body.should == "pants"
  end

  it "should have a permalink after saving" do
    post = Post.new("title" => "pants are awesome")
    post.save
    post.permalink.should == "pants-are-awesome"
  end
end
