module Takeable
  extend ActiveSupport::Concern

  def take_by_projekt_phases(scoped_projekt_phases_ids)
    @resources = @resources.joins(projekt_phase: :projekt).merge(Projekt.activated)

    if controller_name.in?(["debates", "proposals", "polls"])
      projekts_visible_in_sidebar_ids = Projekt.show_in_sidebar(controller_name).ids
      @resources.joins(projekt_phase: :projekt).where(projekts: { id: projekts_visible_in_sidebar_ids })
    end

    @resources = @resources.where(projekt_phases: { id: scoped_projekt_phases_ids })

    @all_resources = @resources

    if params[:filter_projekt_ids].present?
      @resources = @resources.where(projekts: { id: params[:filter_projekt_ids].split(",") })
    end
  end

  def take_by_projekts(scoped_projekts_ids)
    @resources = @resources.joins(projekt_phase: :projekt)
      .merge(Projekt.activated.with_active_feature("general.show_in_sidebar_filter"))
    @resources = @resources.where(projekts: { id: scoped_projekts_ids }).distinct

    @all_resources = @resources

    if params[:filter_projekt_ids].present?
      @resources = @resources.where(projekts: { id: params[:filter_projekt_ids].split(",") })
    end
  end

  def take_by_projekt_labels
    return if params[:projekt_label_ids].blank?

    @resources = @resources
      .joins(:projekt_labels)
      .where(projekt_labels: { id: params[:projekt_label_ids] })
      .distinct
  end

  def take_by_sentiment
    return if params[:sentiment_id].blank?

    @resources = @resources
      .where(sentiment_id: params[:sentiment_id])
      .distinct
  end

  def take_by_tag_names(related_projekts)
    if params[:tags].present?
      tagged_related_projekt_ids = related_projekts
        .tagged_with(params[:tags]
        .split(","), all: true, any: true)
        .ids

      @resources = @resources
        .joins(projekt_phase: :projekt)
        .where(projekts: { id: tagged_related_projekt_ids })

      @all_resources = @resources
    end
  end

  def take_by_sdgs(related_projekts)
    if params[:sdg_targets].present?
      @filtered_goals = params[:sdg_goals].split(",").map(&:to_i)
      selected_related_projekt_ids = related_projekts
        .joins(:sdg_global_targets).where(sdg_targets: { code: params[:sdg_targets] }).ids.uniq
    elsif params[:sdg_goals].present?
      @filtered_goals = params[:sdg_goals].split(",").map(&:to_i)
      selected_related_projekt_ids = related_projekts
        .joins(:sdg_goals).where(sdg_goals: { code: @filtered_goals }).ids.uniq
    end

    if selected_related_projekt_ids.present?
      @resources = @resources
        .joins(projekt_phase: :projekt)
        .where(projekts: { id: selected_related_projekt_ids })

      @all_resources = @resources
    end
  end

  def take_by_geozone_affiliations
    case @selected_geozone_affiliation
    when "all_resources"
      @resources
    when "no_affiliation"
      @resources = @resources.joins(projekt_phase: :projekt).where(projekts: { geozone_affiliated: "no_affiliation" })
    when "entire_city"
      @resources = @resources.joins(projekt_phase: :projekt).where(projekts: { geozone_affiliated: "entire_city" })
    when "only_geozones"
      @resources = @resources.joins(projekt_phase: :projekt).where(projekts: { geozone_affiliated: "only_geozones" })

      if @affiliated_geozones.present?
        @resources = @resources.joins(:geozone_affiliations).where(geozones: { id: @affiliated_geozones })
      else
        @resources = @resources.joins(:geozone_affiliations).where.not(geozones: { id: nil })
      end
    end
    @all_resources = @resources
  end

  def take_by_geozone_restrictions
    case @selected_geozone_restriction
    when "no_restriction"
      @resources = @resources.joins(:projekt_phase)
    when "only_citizens"
      @resources = @resources.joins(:projekt_phase).where(projekt_phases: { geozone_restricted: ["only_citizens", "only_geozones"] })
    when "only_geozones"
      @resources = @resources.joins(:projekt_phase).where(projekt_phases: { geozone_restricted: "only_geozones" })

      if @restricted_geozones.present?
        @resources = @resources.joins(:geozone_restrictions).where(geozone_restrictions: { geozones: { id: @restricted_geozones }})
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
