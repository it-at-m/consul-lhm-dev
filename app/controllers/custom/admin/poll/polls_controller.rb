require_dependency Rails.root.join("app", "controllers", "admin", "poll", "polls_controller").to_s
class Admin::Poll::PollsController < Admin::Poll::BaseController

  before_action :set_projekts_for_selector, only: [:new, :edit, :update]

  def index
    respond_to do |format|
      format.html
      format.csv do
        send_data Poll::CsvExporter.new(@polls.limit(2000)).to_csv,
          filename: "polls.csv"
      end
    end
  end

  private

    def poll_params
      attributes = [:name, :starts_at, :ends_at, :geozone_restricted, :budget_id, :projekt_id, :related_sdg_list, :show_open_answer_author_name,
                    :show_summary_instead_of_questions,
                    :tag_list, geozone_ids: [], image_attributes: image_attributes]

      params.require(:poll).permit(*attributes, *report_attributes, translation_params(Poll))
    end
end
