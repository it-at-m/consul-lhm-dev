module Abilities
  module DeficiencyReports
    class Officer
      include CanCan::Ability

      def initialize(user)
        merge Abilities::Common.new(user)
        dr_officer = user.deficiency_report_officer
        can [:update_official_answer], ::DeficiencyReport, officer: dr_officer
      end
    end
  end
end
