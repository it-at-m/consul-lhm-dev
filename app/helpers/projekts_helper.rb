module ProjektsHelper
  def link_to_projekt_page(projekt)
    if projekt.page.published?
      content_tag(:i, '', class: "fas fa-#{projekt.icon || 'circle'}") +
        link_to(projekt.page.title, projekt.page.url)
    elsif projekt.parent.present? && projekt.parent.page.published?
      content_tag(:i, '', class: "fas fa-#{projekt.parent.icon || 'circle'}") +
        link_to(projekt.parent.page.title, projekt.parent.page.url)
    end
  end

  def projekt_bar_background_color(projekt)
    if projekt.page.published?
      projekt.color
    elsif projekt.parent.present? && projekt.parent.page.published?
      projekt.parent.color
    else
      '#FFFFFF'
    end
  end

  def projekt_bar_text_color(projekt)
    if projekt.page.published?
      pick_text_color(projekt.color)
    elsif projekt.parent.present? && projekt.parent.page.published?
      pick_text_color(projekt.parent.color)
    else
      '#000000'
    end
  end

  def show_archived_projekts_in_sidebar?
    Setting["projekts.show_archived.sidebar"].present? ? true : false
  end

  def show_archived_projekts_in_menu?
    Setting["projekts.show_archived.navigation"].present? ? true : false
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
    link_to anchor_text, (debates_path + "?projekts=#{projekt.all_children_ids.push(projekt.id).join(',')}"), class: (class_name + ' js-reset-projekt-filter-toggle-status'), data: { projekts: projekt.all_parent_ids.push(projekt.id).join(','), resources: 'debates' }
  end

  def proposals_overview_link(anchor_text, projekt, class_name)
    link_to anchor_text, (proposals_path + "?projekts=#{projekt.all_children_ids.push(projekt.id).join(',')}"), class: (class_name + ' js-reset-projekt-filter-toggle-status'), data: { projekts: projekt.all_parent_ids.push(projekt.id).join(','), resources: 'proposals' }
  end

  def polls_overview_link(anchor_text, projekt, class_name)
    link_to anchor_text, (polls_path + "?projekts=#{projekt.all_children_ids.push(projekt.id).join(',')}"), class: (class_name + ' js-reset-projekt-filter-toggle-status'), data: { projekts: projekt.all_parent_ids.push(projekt.id).join(','), resources: 'polls' }
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
    projekt.send(phase_name).active &&
      ((projekt.send(phase_name).start_date <= Date.today if projekt.send(phase_name).start_date) || projekt.send(phase_name).start_date.blank? )
  end

  def format_date(date)
    return '' if date.blank?
    date.strftime("%d.%m.%Y")
  end

  def format_date_range(start_date=nil, end_date=nil, options={})
    options[:separator] ||= '-'
    options[:separator] = ' ' + options[:separator] + ' '
    options[:prefix].present? ? options[:prefix] = options[:prefix] + ' ' : options[:prefix] = ''

    if start_date && end_date
      options[:prefix] + format_date(start_date) + options[:separator] + format_date(end_date)
    elsif start_date && !end_date
      "Start #{format_date(start_date)}"
    elsif !start_date && end_date
      "bis #{format_date(end_date)}"
    else
      'Zeitlich nicht beschränkt'
    end
  end

  def get_projekt_phase_duration(phase)
    if phase
      format_date_range(phase.start_date, phase.end_date)
    else
      format_date_range
    end
  end

  def get_projekt_affiliation_name(projekt)
    affiliation_name = projekt.geozone_affiliated || "no_affiliation"
    geozone_affiliations = projekt.geozone_affiliations

    if geozone_affiliations.exists? && affiliation_name == 'only_geozones'
      return geozone_affiliations.pluck(:name).join(', ')
    end

    t("custom.geozones.projekt_selector.affiliations.#{affiliation_name}" )
  end

  def get_projekt_phase_restriction_name(projekt_phase, destination=nil)
    restriction_name = projekt_phase.geozone_restricted || "no_restriction"
    geozone_restrictions = projekt_phase.geozone_restrictions

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
