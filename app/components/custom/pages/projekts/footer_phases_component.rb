class Pages::Projekts::FooterPhasesComponent < ApplicationComponent
  delegate :format_date, :format_date_range, :get_projekt_phase_restriction_name, :projekt_feature?, to: :helpers
  attr_reader :projekt, :default_phase_name, :phases, :milestone_phase,
              :projekt_notification_phase, :newsfeed_phase, :event_phase,
              :projekt_events, :projekt_events_count

  def initialize(projekt, default_phase_name)
    @projekt = projekt
    @default_phase_name = default_phase_name

    @phases = projekt.regular_projekt_phases.sort{ |a, b| a.default_order <=> b.default_order }
      .each{ |x| x.start_date = Date.today if x.start_date.nil? }
      .sort_by{ |a| a.start_date }
    @milestone_phase = projekt.milestone_phase
    @projekt_notification_phase = projekt.projekt_notification_phase
    @newsfeed_phase = projekt.newsfeed_phase
    @event_phase = projekt.event_phase

    scoped_projekt_ids = @projekt.all_children_projekts.unshift(@projekt).pluck(:id)
    @comments_count = @projekt.comments.count
    @debates_count = Debate.base_selection(scoped_projekt_ids).count
    @proposals_count = Proposal.base_selection(scoped_projekt_ids).count
    @polls_count = Poll.base_selection(scoped_projekt_ids).count
    @projekt_events = ProjektEvent.base_selection(scoped_projekt_ids)
    @projekt_events_count = @projekt_events.count
  end

  private

  def show_arrows?
    phases_total = @phases.to_a

    phases_total += [milestone_phase, projekt_notification_phase, newsfeed_phase, event_phase].compact

    phases_total.select(&:phase_info_activated?).size > 4
  end

  def phase_name(phase)
    t("custom.projekts.phase_name.#{phase.name}")
  end
end
