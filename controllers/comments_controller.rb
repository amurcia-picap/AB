class CommentsController < ApplicationController

  include RecentActivities

  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :load_commentable, except: [:activity_stream_quick_comment]

  def index
    @comments = @commentable.comments
  end

  def new
    @comment = @commentable.comments.new
  end

  def edit
    @commentable = @comment.commentable
    session[:referring_page] = request.referer || comments_path
    render
  end

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @commentable, notice: "Comment created." }
        format.js do
          # We only need following objects for JS requests.
          case @comment.commentable_type
          when "Lead"
            @lead = @comment.commentable
            @lead_recent_activities, @activities_url = lead_activities(@lead, params[:activity_feed_page])
          when "Contact"
            @contact = @comment.commentable
            @contact_recent_activities, @activities_url = contact_activities(@contact, params[:activity_feed_page])
          end
        end
      else
        format.html do
          flash.now[:danger] = "Please check your entry and try again."
          render :new
        end
        format.js
      end
    end
  end

  def update
    @commentable = @comment.commentable
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @commentable, notice: "Comment updated." }
        format.json { head :no_content }
      else
        format.html do
          flash.now[:danger] = "Please check your entry and try again."
          render :edit
        end
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
      format.js
    end
  end

  def activity_stream_quick_comment
    lead = Lead.find(params[:lead_id])
    comment = lead.comments.new
    comment.user = current_user
    comment.content = params[:content]
    respond_to do |format|
      if comment.save
        format.json { render json: "success" }
      else
        format.json { render json: "fail" }
      end
    end
  end

  def destroy
    @commentable = @comment.commentable
    session[:referring_page] = request.referer || @commentable
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to session[:referring_page] || @commentable }
      format.js
      format.json { head :no_content }
    end
  end

  def open_comment_modal
    @comment = @commentable.comments.new
    session[:referring_page] = request.referer || comments_path
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :created_at, :user_id)
  end

  def load_commentable
    if params[:commentable_type] == "Lead"
      @commentable = Lead.find(params[:commentable_id])
    elsif params[:commentable_type] == "Contact"
      @commentable = Contact.find(params[:commentable_id])
    else
      resource, id = request.path.split("/")[1, 2]
      @commentable = resource.singularize.classify.constantize.find(id)
    end
    # Alternate method for custom URLs:
    # klass = [Contact, Client].detect { |c| params["#{c.name.underscore}_id"] }
    # @commentable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

end
