class WorksController < ApplicationController
  before_action :category_from_work, except: [:root, :index, :new, :create]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  skip_before_action :require_login, only: [:root]
  
  def root
    @albums = Work.best_albums
    @books = Work.best_books
    @movies = Work.best_movies
    @best_work = Work.order(vote_count: :desc).first
    @login_user = User.find_by(id: session[:user_id])
  end
  
  def index
    @works_by_category = Work.to_category_hash
  end
  
  def new
    @work = Work.new
  end
  
  def create
    @work = Work.new(media_params)
    @media_category = @work.category
    @work.user_id = session[:user_id]
    if @work.save
      flash[:status] = :success
      flash[:result_text] = "Successfully created #{@media_category.singularize} #{@work.id}"
      redirect_to work_path(@work)
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not create #{@media_category.singularize}"
      flash[:messages] = @work.errors.messages
      render :new, status: :bad_request
    end
  end
  
  def show
    @votes = @work.votes.order(created_at: :desc)
  end
  
  def edit
  end
  
  def update
    @work.update_attributes(media_params)
    if @work.save
      flash[:status] = :success
      flash[:result_text] = "Successfully updated #{@media_category.singularize} #{@work.id}"
      redirect_to work_path(@work)
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not update #{@media_category.singularize}"
      flash.now[:messages] = @work.errors.messages
      render :edit, status: :not_found
    end
  end
  
  def destroy
    @work.destroy
    flash[:status] = :success
    flash[:result_text] = "Successfully destroyed #{@media_category.singularize} #{@work.id}"
    redirect_to root_path
  end
  
  def upvote
    vote = Vote.new(user: @login_user, work: @work)
    if vote.save
      flash[:status] = :success
      flash[:result_text] = "Successfully upvoted!"
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not upvote"
      flash[:messages] = vote.errors.messages
    end
    redirect_back fallback_location: work_path(@work)
  end
  
  private
  
  def media_params
    params.require(:work).permit(:title, :category, :creator, :description, :publication_year)
  end
  
  def category_from_work
    @work = Work.find_by(id: params[:id])
    render_404 unless @work
    @media_category = @work.category.downcase.pluralize
  end

  def require_same_user
    if @work.user_id != session[:user_id]
      flash[:status] = :failure
      flash[:result_text] = "Could not edit work not belong to you!"
      return redirect_to root_path
    end
  end
end
