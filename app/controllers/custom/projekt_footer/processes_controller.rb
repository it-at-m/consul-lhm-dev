class ProjektFooter::ProcessesController < Legislation::BaseController
  include RandomSeed

  has_filters %w[open past], only: :index
  has_filters %w[random winners], only: :proposals

  load_and_authorize_resource

  before_action :set_random_seed, only: :proposals

  def show_projekt_footer
    draft_version = @process.draft_versions.published.last

    if @process.homepage_enabled? && @process.homepage.present?
      render :show
    end
  end

  private

  def member_method?
    params[:id].present?
  end

  def set_process
    return if member_method?

    @process = ::Legislation::Process.find(params[:process_id])
  end
end
