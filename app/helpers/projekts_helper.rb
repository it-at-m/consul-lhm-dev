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

  def prepare_projekt_modules_links(projekt)

    module_links = []

    if debate_phase_active?(projekt)
      link = link_to t('custom.menu.debates'), (debates_path + "?projekts=#{projekt.all_children_ids.push(projekt.id).join(',')}"), class: 'projekt-module-link'
      module_links.push(link)
    end

    if proposal_phase_active?(projekt)
      link = link_to t('custom.menu.proposals'), (proposals_path + "?projekts=#{projekt.all_children_ids.push(projekt.id).join(',')}"), class: 'projekt-module-link'
      module_links.push(link)
    end

    if related_polls_exist?(projekt)
      link = link_to t('custom.menu.polls'), (polls_path + "?projekts=#{projekt.all_children_ids.push(projekt.id).join(',')}"), class: 'projekt-module-link'
      module_links.push(link)
    end

    module_links.join(' | ').html_safe
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

  def format_date(date)
    return '' if date.blank?
    date.strftime("%d.%m.%Y")
  end

  def format_date_range(start_date=nil, end_date=nil)
    if start_date && end_date
      "#{format_date(start_date)} - #{format_date(end_date)}"
    elsif start_date && !end_date
      "Start #{format_date(start_date)}"
    elsif !start_date && end_date
      "bis #{format_date(end_date)}"
    else
      'Ohne zeitliche Beschränkung'
    end
  end

  def format_polls_range(projekt)
    matching_polls = Poll.joins(:projekts).where(projekts: {id: projekt.all_children_ids.push(projekt.id) }).distinct

    if matching_polls.count == 1
      return format_date_range(matching_polls.first.starts_at, matching_polls.first.ends_at)
    else
      return "#{matching_polls.count} aktive"
    end
  end
end
