class Pages::Projekts::FooterPhaseTabComponent < ApplicationComponent
  delegate :format_date, :format_date_range, :get_projekt_phase_restriction_name, :current_user, :projekt_feature?, to: :helpers
  attr_reader :phase, :default_phase_name, :resource_count

  def initialize(phase, default_phase_name)
    @phase = phase
    @default_phase_name = default_phase_name
    @projekt = phase.projekt
    @projekt_tree_ids = @projekt.all_children_ids.unshift(@projekt.id)
  end

  def link_url
    if phase.projekt.overview_page?
      url_for(controller: "projekts", action: "#{phase.name}_footer_tab", order: params[:order])
    else
      projekt_phase_footer_tab_page_path(@projekt.page, phase)
    end
  end

  private

    def tab_title
      @phase.title
    end
end
