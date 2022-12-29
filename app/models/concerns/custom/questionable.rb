require_dependency Rails.root.join("app", "models", "concerns", "questionable").to_s

module Questionable
  private

    def find_by_attributes(user, title)
      case vote_type
      when "unique", nil
        { author: user }
      when "multiple"
        { author: user, answer: title }
      when "rating_scale"
        { author: user }
      end
    end
end
