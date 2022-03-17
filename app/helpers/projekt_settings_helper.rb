module ProjektSettingsHelper
  def projekt_feature?(projekt, feature)
    setting = ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.#{feature}")
    (setting && (setting.value == 'active' || setting.value == 't'  )) ? true : false
  end

  def show_projekt_phase_in_projekt_page?(projekt, phase_name)
    projekt.send(phase_name).present? && ( projekt_feature?(projekt, "general.show_not_active_phases_in_projekts_page_sidebar") || projekt_phase_active?(projekt, phase_name) )
  end

  def active_tab_in_activity?(projekt, tab)
    if show_projekt_phase_in_projekt_page?(projekt, 'proposal_phase')
      active_tab = 'proposals'
    elsif show_projekt_phase_in_projekt_page?(projekt, 'debate_phase')
      active_tab = 'debates'
    elsif ( projekt_feature?(projekt, "general.show_not_active_phases_in_projekts_page_sidebar") || related_polls(projekt).count > 0 )
      active_tab = 'polls'
    end

    active_tab == tab ? 'is-active' : ''
  end
end
