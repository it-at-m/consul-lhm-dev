module Abilities
  class ProjektManager
    include CanCan::Ability

    def self.resources_to_manage
      [MapLayer, ProjektQuestion, ProjektNotification, ProjektEvent, ProjektLivestream, Milestone, ProgressBar, ProjektArgument]
    end

    def initialize(user)
      merge Abilities::Common.new(user)

      can([:show, :update, :update_map], Projekt) do |p|
        p.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can([:update, :update_standard_phase], ProjektSetting) do |ps|
        ps.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:manage, ProjektPhase) do |pp|
        pp.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:update_map, MapLocation) do |p|
        p.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(%i[read update], SiteCustomization::Page) do |p|
        p.projekt.present? &&
          p.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:manage, ::Widget::Card) do |wc|
        wc.cardable.class == SiteCustomization::Page &&
        wc.cardable.projekt.present? &&
        wc.cardable.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:manage, Abilities::ProjektManager.resources_to_manage) do |resource|
        resource.projekt.present? &&
          resource.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can :block, User
      cannot :block, User, id: user.id

      can :moderate, Proposal, projekt: { projekt_managers: { id: user.projekt_manager.id }}
      can :hide, Proposal, hidden_at: nil, projekt: { projekt_managers: { id: user.projekt_manager.id }}
      can :ignore_flag, Proposal, ignored_flag_at: nil,
                                  hidden_at: nil,
                                  projekt: { projekt_managers: { id: user.projekt_manager.id }}

      can :moderate, Debate, projekt: { projekt_managers: { id: user.projekt_manager.id }}
      can :hide, Debate, hidden_at: nil, projekt: { projekt_managers: { id: user.projekt_manager.id }}
      can :ignore_flag, Debate, ignored_flag_at: nil,
                                hidden_at: nil,
                                projekt: { projekt_managers: { id: user.projekt_manager.id }}

      can :moderate, Budget::Investment, budget: { projekt: { projekt_managers: { id: user.projekt_manager.id }}}
      can :hide, Budget::Investment, hidden_at: nil,
                                     budget: { projekt: { projekt_managers: { id: user.projekt_manager.id }}}
      can :ignore_flag, Budget::Investment, ignored_flag_at: nil,
                                           hidden_at: nil,
                                           budget: { projekt: { projekt_managers: { id: user.projekt_manager.id }}}

      can :moderate, Comment

      can :hide, Comment do |comment|
        comment.projekt.present? &&
          comment.projekt.projekt_manager_ids.include?(user.projekt_manager.id) &&
          comment.hidden_at == nil
      end

      can :ignore_flag, Comment do |comment|
        comment.projekt.present? &&
          comment.projekt.projekt_manager_ids.include?(user.projekt_manager.id) &&
          comment.ignored_flag_at == nil &&
          comment.hidden_at == nil
      end

      can :comment_as_moderator, [Debate, Comment, Proposal, Budget::Investment, Poll, ProjektQuestion], projekt_phase: { projekt: { projekt_managers: { id: user.projekt_manager.id }}}
      can :comment_as_moderator, [Projekt], projekt_managers: { id: user.projekt_manager.id }

      can [:update, :toggle_active_status], ProjektPhase, projekt: { projekt_managers: { id: user.projekt_manager.id }}
    end
  end
end
