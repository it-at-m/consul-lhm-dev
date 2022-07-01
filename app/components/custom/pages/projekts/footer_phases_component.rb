class Pages::Projekts::FooterPhasesComponent < ApplicationComponent
  delegate :format_date, :format_date_range, :get_projekt_phase_restriction_name, to: :helpers
  attr_reader :projekt, :default_phase_name

  def initialize(projekt, default_phase_name)
    @projekt = projekt
    @projekt_tree_ids = projekt.all_children_ids.unshift(projekt.id)
    @default_phase_name = default_phase_name

    @comments_count = @projekt.comments.count
    @debates_count = Debate.where(projekt_id: (Debate.scoped_projekt_ids_for_footer(@projekt) & @projekt_tree_ids)).count
    @proposals_count = Proposal.base_selection.where(projekt_id: (Proposal.scoped_projekt_ids_for_footer(@projekt) & @projekt_tree_ids)).count
    @projekt_questions_count = @projekt.questions.count
    @polls_count = Poll.base_selection.where(projekt_id: (Poll.scoped_projekt_ids_for_footer(@projekt) & @projekt_tree_ids)).count
    @milestones_count = @projekt.milestones.count
    @projekt_notifications_count = @projekt.projekt_notifications.count
    @projekt_events_count = @projekt.projekt_events.count

    @process = @projekt.legislation_process
    @draft_versions = @process&.draft_versions&.published
    @legislation_processes_count = (@draft_versions&.count || 0)
    @text_draft_version = @draft_versions&.last
  end

  private

  def show_arrows?
    projekt.projekt_phases.to_a.select(&:phase_activated?).size > 4
  end

  def phase_name(phase)
    t("custom.projekts.phase_name.#{phase.name}")
  end
end
