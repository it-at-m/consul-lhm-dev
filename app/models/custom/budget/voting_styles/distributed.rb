class Budget::VotingStyles::Distributed < Budget::VotingStyles::Base
  def enough_resources?(investment)
    amount_available(investment.heading) > 0
  end

  def reason_for_not_being_ballotable(investment)
    :not_enough_available_votes unless enough_resources?(investment)
  end

  # def not_enough_resources_error
  #   "insufficient votes"
  # end

  def amount_spent(heading)
    ballot.lines.sum(:line_weight)
  end

  def amount_limit(heading)
    heading.max_ballot_lines
  end

  def format(amount)
    amount
  end
end
