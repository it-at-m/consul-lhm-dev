require_dependency Rails.root.join("app", "models", "concerns", "statisticable").to_s

module Statisticable
  class_methods do
    def gender_methods
      %i[
        total_male_participants
        total_female_participants
        total_other_gen_participants
        male_percentage
        female_percentage
        other_gen_percentage
      ]
    end
  end

  def gender?
    participants.male.any? || participants.female.any? || participants.other_gen.any?
  end

  def other_gen_percentage
    calculate_percentage(total_other_gen_participants, total_participants_with_gender)
  end

  def total_other_gen_participants
    participants.other_gen.count
  end

  def show_percentage_values_only?
    false
  end
end
