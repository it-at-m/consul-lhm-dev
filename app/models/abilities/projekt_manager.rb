module Abilities
  class ProjektManager
    include CanCan::Ability

    def self.resources_to_manage
      [
        ProjektQuestion, ProjektNotification, ProjektEvent, ProjektLivestream, ProjektArgument,
        ProjektLabel, Sentiment, FormularField, FormularFollowUpLetter
      ]
    end

    def initialize(user)
      merge Abilities::Common.new(user)

      can([:index, :edit, :update, :update_map, :order_phases, :update_standard_phase], Projekt) do |p|
        user.projekt_manager.present? && user.projekt_manager.allowed_to?("manage", p)
      end

      can(:manage, Abilities::ProjektManager.resources_to_manage) do |resource|
        resource.projekt_phase.present? &&
          can?(:edit, resource.projekt_phase.projekt)
      end

      can([:update, :update_standard_phase], ProjektSetting) do |ps|
        can? :edit, ps.projekt
      end

      can(:manage, Milestone) do |milestone|
        milestone.milestoneable.is_a?(ProjektPhase::MilestonePhase) &&
          can?(:edit, milestone.milestoneable.projekt)
      end

      can(:manage, ProgressBar) do |progress_bar|
        progress_bar.progressable.is_a?(ProjektPhase) &&
          can?(:edit, progress_bar.progressable.projekt)
      end

      can(:manage, ProjektPhase) do |pp|
        can? :edit, pp.projekt
      end

      can(:update, ProjektPhaseSetting) do |pps|
        can? :edit, pps.projekt_phase.projekt
      end

      can([:edit, :update], SiteCustomization::ContentBlock)
      can([:edit, :update], SiteCustomization::Page) do |page|
        page.projekt.present? &&
          can?(:edit, page.projekt)
      end

      can(:update_map, MapLocation) do |p|
        related_projekt = p.respond_to?(:projekt_phase) ? p.projekt_phase.projekt : p.projekt
        can? :edit, related_projekt
      end

      can(:manage, MapLayer) do |ml|
        related_projekt = ml.mappable.is_a?(ProjektPhase) ? ml.mappable.projekt : ml.mappable
        can? :edit, related_projekt
      end

      can(%i[read update], SiteCustomization::Page) do |page|
        page.projekt.present? &&
          can?(:edit, page.projekt)
      end

      can(:manage, ::Widget::Card) do |wc|
        wc.cardable.class == SiteCustomization::Page &&
          wc.cardable.projekt.present? &&
          can?(:edit, wc.cardable.projekt)
      end

      # Moderation: Users
      can :block, User
      cannot :block, User, id: user.id

      # Moderation: Proposals
      can :moderate, Proposal do |proposal|
        user.projekt_manager.allowed_to?("moderate", proposal.projekt)
      end

      can :hide, Proposal do |proposal|
        proposal.hidden_at == nil &&
          can?(:moderate, proposal)
      end

      can :ignore_flag, Proposal do |proposal|
        proposal.ignored_flag_at == nil &&
          proposal.hidden_at == nil &&
          can?(:moderate, proposal)
      end

      # Moderation: Debates
      can :moderate, Debate do |debate|
        user.projekt_manager.allowed_to?("moderate", debate.projekt)
      end

      can :hide, Debate do |debate|
        debate.hidden_at == nil &&
          can?(:moderate, debate)
      end

      can :ignore_flag, Debate do |debate|
        debate.ignored_flag_at == nil &&
          debate.hidden_at == nil &&
          can?(:moderate, debate)
      end

      # Moderation: Budget::Investments
      can :moderate, Budget::Investment do |investment|
        user.projekt_manager.allowed_to?("moderate", investment.budget&.projekt)
      end

      can :hide, Budget::Investment do |investment|
        investment.hidden_at == nil &&
          can?(:moderate, investment.budget&.projekt)
      end

      can :ignore_flag, Budget::Investment do |investment|
        investment.ignored_flag_at == nil &&
          investment.hidden_at == nil &&
          can?(:moderate, investment.budget&.projekt)
      end

      # Moderation: Budget::Investments
      can :moderate, Comment do |comment|
        user.projekt_manager.allowed_to?("moderate", comment&.projekt)
      end

      can :hide, Comment do |comment|
        comment.hidden_at == nil &&
          can?(:moderate, comment)
      end

      can :ignore_flag, Comment do |comment|
        comment.ignored_flag_at == nil &&
          comment.hidden_at == nil &&
          can?(:moderate, comment)
      end

      # Comment as moderator
      can :comment_as_moderator, [ProjektPhase, Debate, Proposal, Budget::Investment, Poll, ProjektQuestion] do |resource|
        user.projekt_manager.allowed_to?("moderate", resource.projekt)
      end


      can [:read, :create, :update, :destroy], Budget do |budget|
        user.projekt_manager.allowed_to?("manage", budget&.projekt)
      end
      can :publish, Budget, id: Budget.drafting.ids
      can :calculate_winners, Budget, &:reviewing_ballots?
      can :read_results, Budget do |budget|
        user.projekt_manager.allowed_to?("manage", budget&.projekt) &&
          budget.balloting_or_later?
        # budget.balloting_finished? && budget.has_winning_investments?
      end
      can :read_stats, Budget do |budget|
        user.projekt_manager.allowed_to?("manage", budget&.projekt) &&
          Budget.valuating_or_later.stats_enabled.ids.include?(budget.id)
      end

      can :recalculate_winners, Budget, &:balloting_or_later?

      can [:admin_update, :toggle_selection], Budget::Investment do |investment|
        can?(:create, investment.budget)
      end

      can :edit_physical_votes, Budget::Investment do |investment|
        can?(:create, investment.budget) &&
          investment.budget.phase == "selecting"
      end

      can :manage, Poll do |poll|
        user.projekt_manager.allowed_to?("manage", poll&.projekt)
      end

      can :manage, Poll::Question do |question|
        can?(:manage, question.poll)
      end

      can [:manage], Poll::Question::Answer do |answer|
        can?(:manage, answer.question)
      end

      can [:manage], Poll::Question::Answer::Video do |video|
        can?(:manage, video.answer)
      end

      can [:manage], ::Poll::BoothAssignment do |assignment|
        can?(:manage, assignment.poll)
      end

      can [:manage], Legislation::Process do |process|
        user.projekt_manager.allowed_to?("manage", process&.projekt_phase&.projekt)
      end

      can [:manage], ::Legislation::DraftVersion do |draft_version|
        can?(:manage, draft_version&.process)
      end
    end
  end
end
