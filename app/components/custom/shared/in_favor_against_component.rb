require_dependency Rails.root.join("app", "components", "shared", "in_favor_against_component").to_s

class Shared::InFavorAgainstComponent < ApplicationComponent
  def initialize(votable)
    @votable = votable
  end

  private

    def downvoting_allowed?
      votable.respond_to?(:downvoting_allowed?) ? votable.downvoting_allowed? : true
    end
end
