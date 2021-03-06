class ContactActivitiesController < ApplicationController

  before_action :set_contact_activity, only: %i(destroy edit show update)

  def index
    @contact_activities = current_user.marketing_contact_activities.
                          includes(:contact).order("completed_at desc")
  end

  def new
    @contact_activity = current_user.contact_activities.new contact_id: params[:contact_id]
    session[:referring_page] = request.referer
  end

  def show
    redirect_to edit_contact_activity_path(params[:id])
  end

  def edit
    session[:referring_page] = request.referer
  end

  def create
    @user = current_user
    @contact_activity = @user.contact_activities.new(contact_activity_params)
    @redirect_location = params[:redirect_location]

    respond_to do |format|
      if @contact_activity.save
        if @redirect_location == "marketingcenter"
          format.html { redirect_to marketing_center_index_path, notice: "Activity recorded." }
        else
          format.html do
            redirect_to(
              session[:referring_page] || contact_activities_path,
              notice: "Referral activity was successfully created."
            )
          end
        end
        format.json { render action: "show", status: :created, location: @contact_activity }
      else
        format.html do
          flash.now[:danger] = "Please check your entry and try again."
          render :new
        end
        format.json { render json: @contact_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # ACTIVITY STREAM QUICK ADD FORM ACTIONS ---------------------------------------

  def activity_stream_quick_record_note
    user                   = current_user
    activity               = user.contact_activities.new
    activity.activity_type = "Note"
    activity.completed_at  = Time.zone.parse(params[:date])
    activity.subject       = params[:subject]
    activity.comments      = params[:info]
    activity.contact_id    = params[:contact_id]
    activity.lead_id       = params[:lead_id]
    activity.activity_for  = ContactActivity::ACTIVITY_FOR[1]

    respond_to do |format|
      if activity.save
        format.json { render json: "success" }
      else
        format.json { render json: "fail" }
      end
    end
  end

  def activity_stream_quick_record_meeting
    user                   = current_user
    activity               = user.contact_activities.new
    activity.activity_type = "Meeting"
    activity.completed_at  = Time.zone.parse(params[:date] + " " + params[:time])
    activity.subject       = params[:subject]
    activity.comments      = params[:info]
    activity.contact_id    = params[:contact_id]
    activity.lead_id       = params[:lead_id]
    activity.activity_for  = ContactActivity::ACTIVITY_FOR[1]

    respond_to do |format|
      if activity.save
        format.json { render json: "success" }
      else
        format.json { render json: "fail" }
      end
    end
  end

  def activity_stream_quick_record_lunch
    user                   = current_user
    activity               = user.contact_activities.new
    activity.activity_type = "Lunch"
    activity.completed_at  = Time.zone.parse(params[:date] + " " + params[:time])
    activity.subject       = params[:subject]
    activity.comments      = params[:info]
    activity.contact_id    = params[:contact_id]
    activity.lead_id       = params[:lead_id]
    activity.activity_for  = ContactActivity::ACTIVITY_FOR[1]

    respond_to do |format|
      if activity.save
        format.json { render json: "success" }
      else
        format.json { render json: "fail" }
      end
    end
  end

  def activity_stream_quick_record_call
    user                   = current_user
    activity               = user.contact_activities.new
    activity.activity_type = "Call"
    activity.completed_at  = Time.zone.parse(params[:date] + " " + params[:time])
    activity.subject       = params[:subject]
    activity.comments      = params[:info] + " - to number: " + params[:number]
    activity.contact_id    = params[:contact_id]
    activity.lead_id       = params[:lead_id]
    activity.activity_for  = ContactActivity::ACTIVITY_FOR[1]

    respond_to do |format|
      if activity.save
        format.json { render json: "success" }
      else
        format.json { render json: "fail" }
      end
    end
  end

  # ACTIVITY STREAM QUICK ADD FORM ACTIONS /---------------------------------------

  def createinmarketingcenter
    @user = current_user
    @contact_activity = @user.contact_activities.new(contact_activity_params)

    respond_to do |format|
      if @contact_activity.save
        format.html { redirect_to marketing_center_index_path, notice: "Activity completed! Nice work." }
        format.json { render action: "show", status: :created, location: @contact_activity }
      else
        format.html do
          flash.now[:danger] = "Please check your entry and try again."
          render :new
        end
        format.json { render json: @contact_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @contact_activity.update(contact_activity_params)
        format.html do
          redirect_to(
            session[:referring_page],
            notice: "Referral activity was successfully updated."
          )
        end
        format.json { head :no_content }
      else
        format.html do
          flash.now[:danger] = "Please check your entry and try again."
          render :edit
        end
        format.json { render json: @contact_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contact_activity.destroy
    respond_to do |format|
      format.html { redirect_to contact_activities_url }
      format.json { head :no_content }
    end
  end

  def open_contact_activity_modal
    render
  end

  private

  def set_contact_activity
    @contact_activity = ContactActivity.find(params[:id])
  end

  def contact_activity_params
    params.require(:contact_activity).permit(
      :activity_for,
      :activity_type,
      :asked_for_referral,
      :comments,
      :completed_at,
      :contact_id,
      :custom_time,
      :lead_id,
      :subject,
      :user_id,
    )
  end

end
