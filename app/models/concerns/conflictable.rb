module Conflictable
  extend ActiveSupport::Concern

  def conflictive?
    return false unless flags_count > 0 && cached_votes_up > 0
    return false if ignored_flag_at.present? #custom line

    cached_votes_up / flags_count.to_f < 5
  end
end
