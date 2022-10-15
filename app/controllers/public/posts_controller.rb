class Public::PostsController < ApplicationController
  before_action :set_q, only: [:index, :search]
  def index
    @posts = Post.page(params[:page])
    @post = Post.new
    if params[:search].present?
      @posts = Post.posts_serach(params[:search]).page(params[:page])
    elsif params[:tag_id].present?
      @tag = Tag.find(params[:tag_id])
      @posts = @tag.posts.order(created_at: :desc).page(params[:page])
    else
      @posts = Post.all.order(created_at: :desc).page(params[:page])
    end
    @tag_lists = Tag.all
  end
  
  def guest_sign_in
    user = User.find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
    end
    sign_in user
    redirect_to root_path, notice: 'ゲストユーザーとしてログインしました。'
  end
  
  def new
     @post = Post.new
     @pens = @post.pens.build
  end

  def create
    @post = Post.new(post_params)
    tag_list = params[:post][:tag_name].split(/[[:blank:]]/)
    @post.image.attach(params[:post][:image])
    @post.user_id = current_user.id
    if @post.save
      @post.save_posts(tag_list)
      redirect_to post_path(@post.id)
    else
      flash[:alret] = "*は必須です。"
      render :new
    end
  end

  def show
    @post = Post.find(params[:id])
    @pen = 
    @post_comment = PostComment.new
  end

  def edit
    @post = Post.find(params[:id])

  end

  def update
    @post = Post.find(params[:id])
    tag_list = params[:post][:tag_name].split(/[[:blank:]]/)
    @post.clean_pen
    @post.user_id = current_user.id
    
    if @post.update(post_params)      
       @post.save_posts(tag_list)
       @post.blank_pen
      redirect_to post_path(@post.id)
    else
      flash.now[:alert] = "*は必須です。"
      render :edit
    end
  end
  def destroy
    @post = Post.find(params[:id])
    @post.clean_tag
    @post.destroy
    redirect_to root_path
  end   
  def search
    @results = @q.result
  end
  private
  def set_q
    @q = Post.ransack(params[:q])
    @pens_q = Pen.ransack(params[:use_pen_q], search_key: :use_pen_q)
  end
  def post_params
    params.require(:post).permit(:tag_name, :software, :brush, :image, :comments, :image, :introduction, :twitter,
                                pens_attributes:[:use_pen, :_destroy],)
  end
end
