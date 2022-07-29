module Abilities
  class Moderator
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Moderation.new(user)

      can :comment_as_moderator, [Debate, Comment, Proposal, Budget::Investment, Poll, Poll::Question,
                                  Legislation::Question, Legislation::Annotation, Legislation::Proposal, Topic]
      can :manage, [Debate, Proposal]
    end
  end
end