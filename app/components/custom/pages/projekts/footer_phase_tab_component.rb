class Pages::Projekts::FooterPhaseTabComponent < ApplicationComponent
  delegate :format_date, :format_date_range, :get_projekt_phase_restriction_name, to: :helpers
  attr_reader :phase, :default_phase_name, :resource_count

  def initialize(phase, default_phase_name, resource_count=nil)
    @phase = phase
    @default_phase_name = default_phase_name
    @resource_count = resource_count
  end

  def link_url
    if phase.projekt.overview_page?
      url_for(controller: 'projekts', action: "#{phase.name}_footer_tab", order: params[:order])
    else
      "/#{params[:id]}/#{phase.name}_footer_tab"
    end
  end

  private

  def phase_name(phase)
    t("custom.projekts.phase_name.#{phase.name}")
  end
end
