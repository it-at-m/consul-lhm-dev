class Pages::Projekts::FooterPhasesComponent < ApplicationComponent
  attr_reader :projekt, :default_phase_name

  def initialize(projekt, default_phase_name)
    @projekt = projekt
    @default_phase_name = default_phase_name
  end

  private

    def show_arrows?
      projekt.projekt_phases.to_a.select(&:phase_activated?).size > 4
    end

    def phase_name(phase)
      t("custom.projekts.phase_name.#{phase.name}")
    end
end
