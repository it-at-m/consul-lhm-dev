module Abilities
  class ProjektManager
    include CanCan::Ability

    def self.resources_to_manage
      [ProjektQuestion, ProjektNotification, ProjektEvent, ProjektLivestream, Milestone, ProgressBar, ProjektArgument]
    end

    def initialize(user)
      merge Abilities::Common.new(user)

      can([:index, :edit, :update, :update_map, :order_phases, :update_standard_phase], Projekt) do |p|
        p.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can([:update, :update_standard_phase], ProjektSetting) do |ps|
        ps.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:manage, ProjektPhase) do |pp|
        pp.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:update, ProjektPhaseSetting) do |pps|
        pps.projekt_phase.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:manage, ProjektLabel) do |pl|
        pl.projekt_phase.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:manage, Sentiment) do |s|
        s.projekt_phase.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:manage, ProjektQuestion) do |pq|
        pq.projekt_phase.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:manage, ProjektLivestream) do |pl|
        pl.projekt_phase.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can(:manage, ProjektArgument) do |pa|
        pa.projekt_phase.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
      end

      can([:edit, :update], SiteCustomization::ContentBlock)

      can(:update_map, MapLocation) do |p|
        if p.respond_to?(:projekt_phase)
          p.projekt_phase.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
        else
          p.projekt.projekt_manager_ids.include?(user.projekt_manager.id)
        end
      end

      can(:manage, MapLayer) do |ml|
        ml.mappable&.projekt&.projekt_manager_ids&.include?(user.projekt_manager.id)
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

      can :moderate, Proposal, projekt_phase: { projekt: { projekt_managers: { id: user.projekt_manager.id }}}
      can :hide, Proposal, hidden_at: nil, projekt_phase: { projekt: { projekt_managers: { id: user.projekt_manager.id }}}
      can :ignore_flag, Proposal, ignored_flag_at: nil,
                                  hidden_at: nil,
                                  projekt_phase: { projekt: { projekt_managers: { id: user.projekt_manager.id }}}

      can :moderate, Debate, projekt_phase: { projekt: { projekt_managers: { id: user.projekt_manager.id }}}
      can :hide, Debate, hidden_at: nil, projekt_phase: { projekt: { projekt_managers: { id: user.projekt_manager.id }}}
      can :ignore_flag, Debate, ignored_flag_at: nil,
                                hidden_at: nil,
                                projekt_phase: { projekt: { projekt_managers: { id: user.projekt_manager.id }}}

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
