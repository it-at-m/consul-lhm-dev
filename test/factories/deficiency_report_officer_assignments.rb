FactoryBot.define do
  factory :deficiency_report_officer_assignment, class: 'DeficiencyReport::OfficerAssignment' do
    deficiency_report nil
    officer nil
  end
end
