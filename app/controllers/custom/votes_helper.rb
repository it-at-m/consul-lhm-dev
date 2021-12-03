require_dependency Rails.root.join("app", "helpers", "votes_helper").to_s

module VotesHelper
  def votable_percentage_of_likes(votable)
    votable.likes.percent_of(votable.total_votes)
  end

  def votes_percentage(vote, votable)
    return "0%" if votable.total_votes == 0

    if vote == "likes"
      "#{votable_percentage_of_likes(votable)}%"
    elsif vote == "dislikes"
      "#{100 - votable_percentage_of_likes(votable)}%"
    end
  end
end
