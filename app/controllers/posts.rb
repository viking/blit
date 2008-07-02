class Posts < Application
  
  def index
    @posts = Post.find(:all)
    display @posts
  end

  def show
    @post = Post.find(params[:id])
    display @post
  end

  def new
    render
  end

  def edit
    render
  end

  def delete
    render
  end

  def create
    render
  end

  def update
    render
  end

  def destroy
    render
  end
  
end
