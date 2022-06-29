module Takeable
  extend ActiveSupport::Concern

  def take_by_projekts(scoped_projekts_ids)
    @resources = @resources.joins(:projekt).merge(Projekt.activated)

    if controller_name.in?(['debates', 'proposals', 'polls'])
      projekts_visible_in_sidebar = Projekt.show_in_sidebar(controller_name)
      @resources = @resources.where(projekt: projekts_visible_in_sidebar)
    end

    @resources = @resources.where(projekt_id: scoped_projekts_ids)

    @all_resources = @resources

    if params[:filter_projekt_ids].present?
      @resources = @resources.where(projekt_id: params[:filter_projekt_ids].split(','))
    end
  end

  def take_by_tag_names
    if params[:tags].present?
      @resources = @resources.tagged_with(params[:tags].split(","), all: true, any: :true)
      @all_resources = @resources
    end
  end

  def take_by_sdgs

    if params[:sdg_goals].present? && params[:sdg_targets].present?
      @filtered_goals = params[:sdg_goals].split(',').map{ |code| code.to_i }
      @filtered_target = params[:sdg_targets].split(',')[0]

      @resources = @resources
        .joins(:sdg_goals).where(sdg_goals: { code: @filtered_goals })
        .joins(:sdg_global_targets).where(sdg_targets: { code: @filtered_target })
        .distinct

      @all_resources = @resources
      return
    end

    if params[:sdg_goals].present?
      @filtered_goals = params[:sdg_goals].split(',').map{ |code| code.to_i }
      @resources = @resources.joins(:sdg_goals).where(sdg_goals: { code: @filtered_goals }).distinct
      @all_resources = @resources
      return
    end

    if params[:sdg_targets].present?
      @filtered_target = params[:sdg_targets].split(',')[0]
      @resources = @resources.joins(:sdg_global_targets).where(sdg_targets: { code: @filtered_target }).distinct
      @all_resources = @resources
    end
  end

  def take_by_geozone_affiliations
    case @selected_geozone_affiliation
    when 'all_resources'
      @resources
    when 'no_affiliation'
      @resources = @resources.joins(:projekt).where( projekts: { geozone_affiliated: 'no_affiliation' } ).distinct
    when 'entire_city'
      @resources = @resources.joins(:projekt).where(projekts: { geozone_affiliated: 'entire_city' } ).distinct
    when 'only_geozones'
      @resources = @resources.joins(:projekt).where(projekts: { geozone_affiliated: 'only_geozones' } ).distinct
      if @affiliated_geozones.present?
        @resources = @resources.joins(:geozone_affiliations).where(geozones: { id: @affiliated_geozones }).distinct
      else
        @resources = @resources.joins(:geozone_affiliations).where.not(geozones: { id: nil }).distinct
      end
    end
    @all_resources = @resources
  end

  def take_by_geozone_restrictions
    case controller_name

    when 'debates'
      phase_name = :debate_phase
      sql_query = "
        INNER JOIN projekts AS projekts_debates_join_for_restrictions ON projekts_debates_join_for_restrictions.hidden_at IS NULL AND projekts_debates_join_for_restrictions.id = debates.projekt_id
        INNER JOIN projekt_phases AS debate_phases_debates_join_for_restrictions ON debate_phases_debates_join_for_restrictions.projekt_id = projekts_debates_join_for_restrictions.id AND debate_phases_debates_join_for_restrictions.type IN ('ProjektPhase::DebatePhase')
        INNER JOIN projekt_phase_geozones ON projekt_phase_geozones.projekt_phase_id = debate_phases_debates_join_for_restrictions.id
        INNER JOIN geozones AS geozone_restrictions ON geozone_restrictions.id = projekt_phase_geozones.geozone_id
      "
    when 'proposals'
      phase_name = :proposal_phase
      sql_query = "
        INNER JOIN projekts AS projekts_proposals_join_for_restrictions ON projekts_proposals_join_for_restrictions.hidden_at IS NULL AND projekts_proposals_join_for_restrictions.id = proposals.projekt_id
        INNER JOIN projekt_phases AS proposal_phases_proposals_join_for_restrictions ON proposal_phases_proposals_join_for_restrictions.projekt_id = projekts_proposals_join_for_restrictions.id AND proposal_phases_proposals_join_for_restrictions.type IN ('ProjektPhase::ProposalPhase')
        INNER JOIN projekt_phase_geozones ON projekt_phase_geozones.projekt_phase_id = proposal_phases_proposals_join_for_restrictions.id
        INNER JOIN geozones AS geozone_restrictions ON geozone_restrictions.id = projekt_phase_geozones.geozone_id
      "
    end

    case @selected_geozone_restriction
    when 'no_restriction'
      @resources = @resources.joins(phase_name).distinct
    when 'only_citizens'
      @resources = @resources.joins(phase_name).where(projekt_phases: { geozone_restricted: ['only_citizens', 'only_geozones'] }).distinct
    when 'only_geozones'
      @resources = @resources.joins(phase_name).where(projekt_phases: { geozone_restricted: 'only_geozones' }).distinct

      if @restricted_geozones.present?
        @resources = @resources.joins(sql_query).where(geozone_restrictions: { id: @restricted_geozones }).distinct
      end
    end

    @all_resources = @resources
  end

  def take_by_polls_geozone_restrictions
    case @selected_geozone_restriction
    when 'no_restriction'
      @resources
    when 'only_citizens'
      @resources = @resources.left_outer_joins(:geozones_polls).where("polls.geozone_restricted = ? AND geozones_polls.geozone_id IS NULL", true)
    when 'only_geozones'
      if @restricted_geozones.present?
        @resources = @resources.left_outer_joins(:geozones_polls).where("polls.geozone_restricted = ? AND geozones_polls.geozone_id IN (?)", true, @restricted_geozones)
      else
        @resources = @resources.left_outer_joins(:geozones_polls).where("polls.geozone_restricted = ? AND geozones_polls.geozone_id IS NOT NULL", true)
      end
    end

    @all_resources = @resources
  end

  def take_by_my_posts
    if params[:my_posts_filter] == 'true'
      @resources = @resources.by_author(current_user&.id)
      @all_resources = @resources
    end
  end

  def discard_draft
    @resources = @resources.published
  end

  def discard_archived
    unless @current_order == "archival_date" || params[:selected].present?
      @resources = @resources.not_archived
    end
  end

  def load_retired
    if params[:retired].present?
      @resources = @resources.retired
      @resources = @resources.where(retired_reason: params[:retired]) if Proposal::RETIRE_OPTIONS.include?(params[:retired])
    else
      @resources = @resources.not_retired
    end
  end

  def load_selected
    if params[:selected].present?
      @resources = @resources.selected
    else
      @resources = @resources.not_selected
    end
  end

  def load_featured
    return unless !@advanced_search_terms && @search_terms.blank? && params[:retired].blank? && @current_order != "recommendations"
    return unless controller_name == 'proposals'

    if Setting["feature.featured_proposals"]
      @featured_proposals = Proposal.not_archived.unsuccessful
                            .sort_by_confidence_score.limit(Setting["featured_proposals_number"])
      if @featured_proposals.present?
        set_featured_proposal_votes(@featured_proposals)
        @resources = @resources.where.not(id: @featured_proposals)
      end
    end
  end

  def remove_archived_from_order_links
    @valid_orders.delete("archival_date")
  end

  private

  def get_highest_unique_parent_projekt_id(selected_projekts_ids)
    selected_parent_projekt_id = nil
    top_level_active_projekt_ids = Projekt.top_level.activated.ids
    selected_projekts_ids = selected_projekts_ids.select{ |id| top_level_active_projekt_ids.include? Projekt.find_by(id: id).top_parent.id }
    return nil if selected_projekts_ids.empty?

    selected_projekts = Projekt.where(id: selected_projekts_ids)
    highest_level_selected_projekts = selected_projekts.sort { |a, b| a.level <=> b.level }.group_by(&:level).first[1]

    if highest_level_selected_projekts.size == 1
      highest_level_selected_projekt = highest_level_selected_projekts.first
    end

    if highest_level_selected_projekt && (selected_projekts_ids.map(&:to_i) - highest_level_selected_projekt.all_children_ids.push(highest_level_selected_projekt.id) )
      selected_parent_projekt_id = highest_level_selected_projekts.first.id
    end

    selected_parent_projekt_id
  end
end
