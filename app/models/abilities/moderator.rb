module Abilities
  class Moderator
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Moderation.new(user)

      can :comment_as_moderator, [Debate, Comment, Proposal, Budget::Investment, Poll, Poll::Question, Projekt,
                                  Legislation::Question, Legislation::Annotation, Legislation::Proposal, Topic]

      can [:results, :stats], Poll, projekt_phase: { settings: { key: "feature.resource.intermediate_poll_results_for_admins", value: "active" }}
    end
  end
end
