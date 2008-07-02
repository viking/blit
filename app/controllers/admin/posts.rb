module Admin
class Posts < Application
  
  def index
    @posts = Post.find(:all)
    display @posts
  end

  def show
    redirect url(:edit_post, params[:id])
  end

  def new
    @post = Post.new
    display @post
  end

  def edit
    @post = Post.find(params[:id])
    display @post
  end

  def delete
    @post = Post.find(params[:id])
    display @post
  end

  def create
    @post = Post.new(params[:post])
    @post.save
    redirect url(:post, @post.id)
  end

  def update
    @post = Post.find(params[:id])
    @post.update(params[:post])
    redirect url(:post, @post.id)
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect url(:posts)
  end
  
end
end # end Admin
