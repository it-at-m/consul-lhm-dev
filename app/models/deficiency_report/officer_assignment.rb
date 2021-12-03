class DeficiencyReport::OfficerAssignment < ApplicationRecord
  belongs_to :deficiency_report
  belongs_to :officer
end
