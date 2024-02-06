class Pages::Projekts::SidebarCtaComponent < ApplicationComponent
  def initialize(projekt_phase = nil)
    @projekt_phase = projekt_phase
  end

  def render?
    return false if @projekt_phase.nil?
    return false if @projekt_phase.is_a?(ProjektPhase::BudgetPhase) && !@projekt_phase.budget.accepting?

    @projekt_phase.type.in?(phase_types_with_new_button + phase_types_with_link)
  end

  private

    def phase_types_with_new_button
      %w[
        ProjektPhase::DebatePhase
        ProjektPhase::ProposalPhase
        ProjektPhase::BudgetPhase
      ]
    end

    def phase_types_with_link
      %w[
        ProjektPhase::VotingPhase
        ProjektPhase::QuestionPhase
      ]
    end

    def button_text
      @projekt_phase.cta_button_name.presence || I18n.t("custom.projekt_phases.cta.#{@projekt_phase.name}")
    end
end
