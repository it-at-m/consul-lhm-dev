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
    @deficiency_reports = DeficiencyReport.all.page(params[:page]).send("sort_by_#{@current_order}")

    @categories = DeficiencyReport::Category.all.order(created_at: :asc)
    @statuses = DeficiencyReport::Status.all.order(created_at: :asc)

    @deficiency_reports_coordinates = all_deficiency_report_map_locations(@deficiency_reports)

    @selected_categories_ids = (params[:dr_categories] || '').split(',')
    @selected_status_id = (params[:dr_status] || '').split(',').first
    @selected_officer = params[:dr_officer]

    @deficiency_reports = @deficiency_reports.search(@search_terms) if @search_terms.present?


    filter_by_categories if @selected_categories_ids.present?
    filter_by_selected_status if @selected_status_id.present?
    filter_by_selected_officer if @selected_officer.present?

    set_deficiency_report_votes(@deficiency_reports)
  end

  def show
    @commentable = @deficiency_report
    @comment_tree = CommentTree.new(@deficiency_report, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
    set_deficiency_report_votes(@deficiency_reports)
  end

  def new
    @deficiency_report = DeficiencyReport.new
  end

  def create
    status = DeficiencyReport::Status.first
    @deficiency_report = DeficiencyReport.new(deficiency_report_params.merge(author: current_user, status: status))

    if @deficiency_report.save
      DeficiencyReportMailer.notify_administrators(@deficiency_report).deliver_later
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
    if @deficiency_report.update(deficiency_report_officer_id: deficiency_report_params[:deficiency_report_officer_id])
      DeficiencyReportMailer.notify_officer(@deficiency_report).deliver_later
    end
    redirect_to deficiency_report_path(@deficiency_report)
  end

  def update_official_answer
    @deficiency_report.update(deficiency_report_params)
    redirect_to deficiency_report_path(@deficiency_report)
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

  def load_categories
    @categories = Tag.category.order(:name)
  end

  def deficiency_report_params
    attributes = [:terms_of_service, :video_url,
                  :deficiency_report_status_id,
                  :deficiency_report_category_id,
                  :deficiency_report_officer_id,
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

  def set_view
    @view = (params[:view] == "minimal") ? "minimal" : "default"
  end

end
