module ProjektsHelper
  def breadcrumbs_links(base_projekt, divider = '/', home_page_link = true)
    divider_tag = content_tag(:div, divider, class: 'breadcrumbs-divider')

    links = base_projekt.breadcrumb_trail_ids.map do |projekt_id|
      projekt = Projekt.find(projekt_id)

      if !projekt.page.published? || (projekt == base_projekt && home_page_link)
        content_tag(:div, projekt.title, class: 'breadcrumbs-item')
      else
        link_to projekt.page.title, projekt.page.url, class: 'breadcrumbs-item'
      end
    end

    links.unshift(link_to t('custom.projekt.page.breadcrumbs.homepage'), root_path, class: 'breadcrumbs-item') if home_page_link

    content_tag(:div, safe_join(links, divider_tag).html_safe, class: 'custom-breadcrumbs')
  end

  def projekt_bar_background_color(projekt)
    if projekt.color.present?
      projekt.color
    else
      '#FFFFFF'
    end
  end

  def projekt_bar_text_color(projekt)
    if projekt.color.present?
      pick_text_color(projekt.color)
    else
      '#000000'
    end
  end

  def projekt_filter_resources_name
    @current_tab_phase&.resources_name || controller_name
  end

  def show_archived_projekts_in_sidebar?
    Setting["projekts.show_archived.sidebar"].present? ? true : false
  end

  def show_affiliation_filter_in_sidebar?
    Setting["extended_feature.modulewide.show_affiliation_filter_in_index_sidebar"].present? ? true : false
  end

  def prepare_projekt_name(projekt, placement=nil)
    if projekt.page.published? && placement == 'desktop'
      link_to projekt.page.title, projekt.page.url, tabindex: '-1', aria: { hidden: true }
    elsif  projekt.page.published? && placement == 'mobile'
      link_to projekt.page.title, projekt.page.url
    else
      projekt.page.title
    end
  end

  def prepare_projekt_modules_links(projekt)

    module_links = []

    if projekt_phase_show_in_navigation?(projekt, 'debate_phase')
      module_links.push( debates_overview_link(t('custom.menu.debates'), projekt, 'projekt-module-link') )
    end

    if projekt_phase_show_in_navigation?(projekt, 'proposal_phase')
      module_links.push( proposals_overview_link(t('custom.menu.proposals'), projekt, 'projekt-module-link') )
    end

    if related_polls(projekt).any?
      module_links.push( polls_overview_link(t('custom.menu.polls'), projekt, 'projekt-module-link') )
    end

    module_links.join(' | ').html_safe
  end

  def debates_overview_link(anchor_text, projekt, class_name)
    link_to anchor_text, (debates_path + "?#{projekt.all_children_ids.unshift(projekt.id).to_query('filter_projekt_ids')}"), class: (class_name + ' js-reset-projekt-filter-toggle-status'), data: { projekts: projekt.all_parent_ids.push(projekt.id).join(','), resources: 'debates' }
  end

  def proposals_overview_link(anchor_text, projekt, class_name)
    link_to anchor_text, (proposals_path + "?#{projekt.all_children_ids.unshift(projekt.id).to_query('filter_projekt_ids')}"), class: (class_name + ' js-reset-projekt-filter-toggle-status'), data: { projekts: projekt.all_parent_ids.push(projekt.id).join(','), resources: 'proposals' }
  end

  def polls_overview_link(anchor_text, projekt, class_name)
    link_to anchor_text, (polls_path + "?#{projekt.all_children_ids.unshift(projekt.id).to_query('filter_projekt_ids')}"), class: (class_name + ' js-reset-projekt-filter-toggle-status'), data: { projekts: projekt.all_parent_ids.push(projekt.id).join(','), resources: 'polls' }
  end

  def projekt_phase_active?(projekt, phase_name)
    projekt.send(phase_name).active
  end

  def projekt_phase_not_started_yet?(projekt, phase_name)
    projekt.send(phase_name).start_date > Date.today if projekt.send(phase_name).start_date
  end

  def projekt_phase_expired?(projekt, phase_name)
    projekt.send(phase_name).end_date < Date.today if projekt.send(phase_name).end_date
  end

  def projekt_phase_show_in_navigation?(projekt, phase_name)
    projekt.send(phase_name).phase_activated? &&
      ((projekt.send(phase_name).start_date <= Date.today if projekt.send(phase_name).start_date) || projekt.send(phase_name).start_date.blank? )
  end

  def format_date(date)
    return '' if date.blank?
    l date.to_date
  end

  def format_date_range(start_date=nil, end_date=nil, options={})
    options[:separator] ||= '-'
    options[:separator] = ' ' + options[:separator] + ' '
    options[:prefix].present? ? options[:prefix] = options[:prefix] + ' ' : options[:prefix] = ''

    # if start_date && end_date
    #   options[:prefix] + format_date(start_date) + options[:separator] + format_date(end_date)
    # elsif start_date && !end_date
    #  "Start #{format_date(start_date)}"
    # elsif !start_date && end_date
    #  "bis #{format_date(end_date)}"
    # else
    #  'Zeitlich nicht beschränkt'
    # end

    if end_date.present? && end_date.to_date < Date.today
      "Abgeschlossen am #{l end_date.to_date}"
    elsif end_date.present?  && end_date.to_date > Date.today && start_date.present? && start_date.to_date <= Date.today
      days_left = (end_date.to_date - Date.today).to_i
      t('custom.shared.dates.days_left', count: days_left)
    elsif end_date.present? && end_date.to_date == Date.today && start_date.present? && start_date.to_date <= Date.today
      "Endet heute"
    elsif start_date.present? && start_date.to_date > Date.today
      days_left = (start_date.to_date - Date.today).to_i
      t('custom.shared.dates.starts_in_days', count: days_left)
    end
  end

  def get_projekt_phase_duration(phase)
    if phase
      format_date_range(phase.start_date, phase.end_date)
    else
      format_date_range
    end
  end

  def get_projekt_affiliation_name(projekt, only_name = false )
    affiliation_name = projekt.geozone_affiliated || "no_affiliation"
    geozone_affiliations = projekt.geozone_affiliations

    if geozone_affiliations.exists? && affiliation_name == 'only_geozones'
      return geozone_affiliations.pluck(:name).join(', ')
    end

    return affiliation_name if only_name

    t("custom.geozones.projekt_selector.affiliations.#{affiliation_name}" )
  end

  def get_projekt_phase_restriction_name(projekt_phase, destination=nil, only_name=false)
    restriction_name = projekt_phase.geozone_restricted || "no_restriction"
    geozone_restrictions = projekt_phase.geozone_restrictions

    return restriction_name if only_name

    if geozone_restrictions.exists? && restriction_name == 'only_geozones'
      return geozone_restrictions.pluck(:name).join(', ')
    end

    if destination == 'projekt_selector'
      t("custom.geozones.projekt_selector.restrictions.#{restriction_name}" )
    else
      t("custom.geozones.sidebar_filter.restrictions.#{restriction_name}" )
    end
  end

  def related_polls(projekt, timestamp = Date.current.beginning_of_day)
    Poll.where(projekt_id: projekt.all_children_ids.push(projekt.id))
  end
end
