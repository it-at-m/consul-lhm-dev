class DeficiencyReportsController < ApplicationController
  include Translatable
  include MapLocationAttributes
  include ImageAttributes
  include DocumentAttributes
  include DeficiencyReportsHelper
  include Search

  before_action :authenticate_user!, except: [:index, :show, :json_data]
  before_action :load_categories
  before_action :set_view, only: :index
  before_action :destroy_map_location_association, only: :update
  load_and_authorize_resource

  has_orders ->(c) { DeficiencyReport.deficiency_report_orders }, only: :index
  has_orders %w[newest most_voted oldest], only: :show

  def index
    if params[:order].nil? &&
         Setting["projekts.set_default_sorting_to_newest"].present? &&
         @valid_orders.include?("created_at")
      @current_order = "created_at"
    end

    @areas = DeficiencyReport::Area.all.order(created_at: :asc)

    if params[:dr_area].present?
      @selected_area = DeficiencyReport::Area.find_by(id: params[:dr_area])
      @map_location = @selected_area.map_location
      @all_deficiency_reports = @selected_area.deficiency_reports
    else
      @all_deficiency_reports = DeficiencyReport.all
    end

    @deficiency_reports = @all_deficiency_reports.send("sort_by_#{@current_order}").page(params[:page])

    @categories = DeficiencyReport::Category.all.order(created_at: :asc)
    @statuses = DeficiencyReport::Status.all.order(given_order: :asc)

    @selected_categories_ids = (params[:dr_categories] || '').split(',')
    @selected_status_id = (params[:dr_status] || '').split(',').first
    @selected_officer = params[:dr_officer]

    @deficiency_reports = @deficiency_reports.search(@search_terms) if @search_terms.present?

    filter_by_categories if @selected_categories_ids.present?
    filter_by_selected_status if @selected_status_id.present?
    filter_by_selected_officer if @selected_officer.present?
    filter_by_approval_status if params[:approval_status].present?
    filter_by_my_posts

    @deficiency_reports_coordinates = all_deficiency_report_map_locations(@deficiency_reports)

    set_deficiency_report_votes(@deficiency_reports)

    respond_to do |format|
      format.html do
        if Setting.new_design_enabled?
          render :index_new
        else
          render :index
        end
      end

      format.csv do
        formated_time = Time.current.strftime("%d-%m-%Y-%H-%M-%S")
        send_data DeficiencyReport::CsvExporter.new(@deficiency_reports.limit(nil)).to_csv,
          filename: "deficiency_reports-#{formated_time}.csv"
      end
    end
  end

  def show
    @commentable = @deficiency_report
    @comment_tree = CommentTree.new(@deficiency_report, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
    set_deficiency_report_votes(@deficiency_reports)

    if Setting.new_design_enabled?
      render :show_new
    else
      render :show
    end
  end

  def new
    @deficiency_report = DeficiencyReport.new
  end

  def create
    status = DeficiencyReport::Status.first

    if deficiency_report_params["image_attributes"]["cached_attachment"].blank?
      filtered_deficiency_report_params = deficiency_report_params.except("image_attributes")
    else
      filtered_deficiency_report_params = deficiency_report_params
    end

    @deficiency_report = DeficiencyReport.new(filtered_deficiency_report_params.merge(author: current_user, status: status))

    if @deficiency_report.save
      NotificationServices::NewDeficiencyReportNotifier.new(@deficiency_report.id).call
      redirect_to deficiency_report_path(@deficiency_report)
    else
      render :new
    end
  end

  def destroy
    @deficiency_report.destroy

    redirect_to deficiency_reports_path
  end

  def update_status
    if @deficiency_report.update(deficiency_report_status_id: deficiency_report_params[:deficiency_report_status_id])
      DeficiencyReportMailer.notify_author_about_status_change(@deficiency_report).deliver_later
    end
    redirect_to deficiency_report_path(@deficiency_report)
  end

  def update_category
    @deficiency_report.update(deficiency_report_category_id: deficiency_report_params[:deficiency_report_category_id])
    redirect_to deficiency_report_path(@deficiency_report)
  end

  def update_officer
    if @deficiency_report.update(
      deficiency_report_officer_id: deficiency_report_params[:deficiency_report_officer_id],
      assigned_at: Time.zone.now
    )
      DeficiencyReportMailer.notify_officer(@deficiency_report).deliver_later
    end
    redirect_to deficiency_report_path(@deficiency_report)
  end

  def notify_officer_about_new_comments
    enable = deficiency_report_params[:notify_officer_about_new_comments] == "1"
    datetime = enable ? Time.current : nil

    if @deficiency_report.update!(
      notify_officer_about_new_comments: deficiency_report_params[:notify_officer_about_new_comments],
      notified_officer_about_new_comments_datetime: datetime
    ) && enable
      last_comment_date = @deficiency_report.comments.last.created_at
      last_comment_date_expanded = last_comment_date - 5.minutes
      new_comments = @deficiency_report.comments.created_after_date(last_comment_date_expanded)

      if new_comments.any?
        NotificationServiceMailer.new_comments_for_deficiency_report(
          @deficiency_report,
          last_comment_date_expanded
        ).deliver_now
      end
    end

    head :ok
  end

  def update_official_answer
    @deficiency_report.update(deficiency_report_params)
    Administrator.all.each do |admin|
      DeficiencyReportMailer.notify_administrators_about_answer_update(@deficiency_report, admin.user).deliver_later
    end
    redirect_to deficiency_report_path(@deficiency_report), notice: t("custom.deficiency_reports.notifications.official_answer_updated")
  end

  def approve_official_answer
    @deficiency_report.update(official_answer_approved: true)
    redirect_to deficiency_report_path(@deficiency_report)
  end

  def vote
    @deficiency_report.register_vote(current_user, params[:value])
    set_deficiency_report_votes(@deficiency_report)
  end

  private

  def filter_by_my_posts
    return unless params[:my_posts_filter] == 'true'

    @deficiency_reports = @deficiency_reports.by_author(current_user&.id)
  end

  def load_categories
    @categories = Tag.category.order(:name)
  end

  def deficiency_report_params
    attributes = [:video_url, :on_behalf_of,
                  :terms_of_service, :terms_data_storage, :terms_data_protection, :terms_general, :resource_terms,
                  :deficiency_report_status_id,
                  :deficiency_report_category_id,
                  :deficiency_report_officer_id,
                  :deficiency_report_area_id,
                  :notify_officer_about_new_comments,
                  map_location_attributes: map_location_attributes,
                  documents_attributes: document_attributes,
                  image_attributes: image_attributes]
    params.require(:deficiency_report).permit(attributes, translation_params(DeficiencyReport))
  end


  def destroy_map_location_association
    map_location = params[:deficiency_report][:map_location_attributes]
    if map_location && (map_location[:longitude] && map_location[:latitude]).blank? && !map_location[:id].blank?
      MapLocation.destroy(map_location[:id])
    end
  end

  def filter_by_categories
    @deficiency_reports = @deficiency_reports.where(category: @selected_categories_ids)
  end

  def filter_by_selected_status
    @deficiency_reports = @deficiency_reports.where(status: @selected_status_id)
  end

  def filter_by_selected_officer
    if @selected_officer == 'current_user'
      @deficiency_reports = @deficiency_reports.joins(:officer).where(deficiency_report_officers: { user_id: current_user.id })
    else
      @deficiency_reports
    end
  end

  def filter_by_approval_status
    if params[:approval_status] == 'not_approved'
      @deficiency_reports = @deficiency_reports.
        where.not(official_answer: '').
        where(official_answer_approved: false)
    end
  end

  def set_view
    @view = (params[:view] == "minimal") ? "minimal" : "default"
  end
end
