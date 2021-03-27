module ProjektsHelper
  def show_archived_projekts_in_sidebar?
    Setting["projekts.show_archived.sidebar"].present? ? true : false
  end

  def show_archived_projekts_in_menu?
    Setting["projekts.show_archived.navigation"].present? ? true : false
  end

  def prepare_projekt_name(projekt)
    if projekt.page.published?
      link_to projekt.name, projekt.page.url
    else
      projekt.name
    end
  end

  def debate_phase_active?(projekt)
    top_parent = projekt.top_parent

    return false unless ( top_parent.debate_phase_start || top_parent.total_duration_start )
    return false unless ( top_parent.debate_phase_end || top_parent.total_duration_end )

    if top_parent.debate_phase_active && (top_parent.debate_phase_start || top_parent.total_duration_start) < Date.today && (top_parent.debate_phase_end || top_parent.total_duration_end ) > Date.today
			return true
    else
			return false
    end
  end

  def proposal_phase_active?(projekt)
    top_parent = projekt.top_parent

    return false unless ( top_parent.proposal_phase_start || top_parent.total_duration_start )
    return false unless ( top_parent.proposal_phase_end || top_parent.total_duration_end )

    if top_parent.proposal_phase_active && (top_parent.proposal_phase_start || top_parent.total_duration_start) < Date.today && (top_parent.proposal_phase_end || top_parent.total_duration_end ) > Date.today
			return true
    else
			return false
    end
  end

  def related_polls_exist?(projekt)
    Poll.joins(:projekts).where(projekts: { id: projekt.all_children_ids.push(projekt.id) }).any?
  end
end
