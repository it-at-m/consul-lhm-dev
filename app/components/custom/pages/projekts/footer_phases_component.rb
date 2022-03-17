class Pages::Projekts::FooterPhasesComponent < ApplicationComponent
  delegate :format_date, :format_date_range, :get_projekt_phase_restriction_name, :projekt_feature?, to: :helpers
  attr_reader :projekt, :default_phase_name, :phases, :milestone_phase

  def initialize(projekt, default_phase_name)
    @projekt = projekt
    @default_phase_name = default_phase_name

    @phases = projekt.regular_projekt_phases.order(:start_date)
    @milestone_phase = projekt.milestone_phase

    scoped_projekt_ids = @projekt.all_children_projekts.unshift(@projekt).pluck(:id)
    @comments_count = @projekt.comments.count
    @debates_count = Debate.base_selection(scoped_projekt_ids).count
    @proposals_count = Proposal.base_selection(scoped_projekt_ids).count
    @polls_count = Poll.base_selection(scoped_projekt_ids).count
  end

  private

  def phase_name(phase)
    t("custom.projekts.phase_name.#{phase.name}")
  end
end
