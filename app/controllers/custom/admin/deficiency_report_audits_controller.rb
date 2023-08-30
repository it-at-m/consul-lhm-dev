class Admin::DeficiencyReportAuditsController < Admin::BaseController
  def show
    deficiency_report = DeficiencyReport.find(params[:deficiency_report_id])
    @audit = deficiency_report.own_and_associated_audits.find(params[:id])

    render "admin/audits/show"
  end
end
