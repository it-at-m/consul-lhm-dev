require_dependency Rails.root.join("app", "models", "concerns", "questionable").to_s

module Questionable
  def max_votes
    votation_type.max_votes || question_answers.count
  end

  private

    def find_by_attributes(user, title)
      case vote_type
      when "unique", nil
        { author: user }
      when "multiple"
        { author: user, answer: title }
      when "multiple_with_weight"
        { author: user, answer: title }
      when "rating_scale"
        { author: user }
      end
    end
end
