require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Posts do
  def do_dispatch
    dispatch_to(Posts, @action, @params) do |controller|
      controller.stub!(:render)
      controller.stub!(:display)
    end
  end

  before(:each) do
    @post = stub(Post)
    @params = {}
  end

  describe "#index" do
    before(:each) do
      @action = :index
      Post.stub!(:find).and_return([@post])
    end

    it "should find all posts" do
      Post.should_receive(:find).with(:all).and_return([@post])
      do_dispatch
    end
  end

  describe "#show" do
    before(:each) do
      @action = :show
      @params[:id] = "1"
      Post.stub!(:find).and_return(@post)
    end

    it "should find the post" do
      Post.should_receive(:find).with("1").and_return(@post)
      do_dispatch
    end
  end

  describe "#new" do
    before(:each) do
      @action = :new
      Post.stub!(:new).and_return(@post)
    end

    it "should create a post" do
      Post.should_receive(:new).and_return(@post)
      do_dispatch
    end
  end

  describe "#edit" do
    before(:each) do
      @action = :edit
      @params[:id] = "1"
      Post.stub!(:find).and_return(@post)
    end

    it "should find the post" do
      Post.should_receive(:find).with("1").and_return(@post)
      do_dispatch
    end
  end

  describe "#delete" do
    before(:each) do
      @action = :delete
      @params[:id] = "1"
      Post.stub!(:find).and_return(@post)
    end

    it "should find the post" do
      Post.should_receive(:find).with("1").and_return(@post)
      do_dispatch
    end
  end

  describe "#create" do
    before(:each) do
      @action = :create
      @params[:post] = {:title => "foo", :body => "bar"}
      @post.stub!(:save)
      @post.stub!(:id).and_return(123)
      Post.stub!(:new).and_return(@post)
    end

    it "should create a post" do
      Post.should_receive(:new).with("title" => "foo", "body" => "bar").and_return(@post)
      do_dispatch
    end

    it "should save the post" do
      @post.should_receive(:save)
      do_dispatch
    end

    it "should redirect to show" do
      do_dispatch.should redirect_to(url(:post, 123))
    end
  end

  describe "#update" do
    before(:each) do
      @action = :update
      @params[:id]   = "1"
      @params[:post] = {:title => "foo", :body => "bar"}

      @post.stub!(:update)
      @post.stub!(:id).and_return(1)
      Post.stub!(:find).and_return(@post)
    end

    it "should find the post" do
      Post.should_receive(:find).with("1").and_return(@post)
      do_dispatch
    end

    it "should update the post" do
      @post.should_receive(:update).with("title" => "foo", "body" => "bar")
      do_dispatch
    end

    it "should redirect to show" do
      do_dispatch.should redirect_to(url(:post, 1))
    end
  end

  describe "#destroy" do
    before(:each) do
      @action = :destroy
      @params[:id]   = "1"

      @post.stub!(:destroy)
      @post.stub!(:id).and_return(1)
      Post.stub!(:find).and_return(@post)
    end

    it "should find the post" do
      Post.should_receive(:find).with("1").and_return(@post)
      do_dispatch
    end

    it "should destroy the post" do
      @post.should_receive(:destroy)
      do_dispatch
    end

    it "should redirect to index" do
      do_dispatch.should redirect_to(url(:posts))
    end
  end
end
