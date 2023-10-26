class Admin::DeficiencyReportsController < Admin::BaseController
  include Translatable

  def index
    @deficiency_reports = DeficiencyReport.all.order(id: :asc)

    unless params[:format] == "csv"
      @deficiency_reports = @deficiency_reports.page(params[:page].presence || 0).per(params[:limit].presence || 20)
    end

    respond_to do |format|
      format.html
      format.csv do
        send_data DeficiencyReport::CsvExporter.new(@deficiency_reports).to_csv,
          filename: "deficiency_reports.csv"
      end
    end
  end

  def show
    @deficiency_report = DeficiencyReport.find(params[:id])
  end
end
