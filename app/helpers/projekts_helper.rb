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

    if projekt_phase_show_in_navigation?(projekt, 'debate_phase')
      link = link_to t('custom.menu.debates'), (debates_path + "?projekts=#{projekt.all_children_ids.push(projekt.id).join(',')}"), class: 'projekt-module-link'
      module_links.push(link)
    end

    if projekt_phase_show_in_navigation?(projekt, 'proposal_phase')
      link = link_to t('custom.menu.proposals'), (proposals_path + "?projekts=#{projekt.all_children_ids.push(projekt.id).join(',')}"), class: 'projekt-module-link'
      module_links.push(link)
    end

    if related_polls(projekt).any?
      link = link_to t('custom.menu.polls'), (polls_path + "?projekts=#{projekt.all_children_ids.push(projekt.id).join(',')}"), class: 'projekt-module-link'
      module_links.push(link)
    end

    module_links.join(' | ').html_safe
  end

  def projekt_phase_active?(projekt, phase_name)
    projekt.send(phase_name).active
  end

  def projekt_phase_selectable?(projekt, phase_name)
    projekt.send(phase_name).active &&
      ((projekt.send(phase_name).start_date <= Date.today if projekt.send(phase_name).start_date) || projekt.send(phase_name).start_date.blank? ) &&
      ((projekt.send(phase_name).end_date >= Date.today if projekt.send(phase_name).end_date) || projekt.send(phase_name).end_date.blank? )
  end

  def projekt_phase_show_in_navigation?(projekt, phase_name)
    projekt.send(phase_name).active &&
      ((projekt.send(phase_name).start_date <= Date.today if projekt.send(phase_name).start_date) || projekt.send(phase_name).start_date.blank? )
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

  def get_projekt_phase_duration(phase)
    if phase
      format_date_range(phase.start_date, phase.end_date)
    else
      format_date_range
    end
  end

  def get_projekt_phase_limitations(phase)
    if phase
      return phase.geozones.names.join(', ') if phase.geozones.any? && phase.geozone_restricted
      return 'Alle Bürger der Stadt' if phase.geozone_restricted
    end
    'Alle Nutzer der Plattform'
  end

  def related_polls(projekt, timestamp = Date.current.beginning_of_day)
    Poll.where(projekt_id: projekt.all_children_ids.push(projekt.id)).where("starts_at <= ? AND ? <= ends_at", timestamp, timestamp)
  end

  def check_radio_button?(current_projekt_id)
    resource = @debate || @proposal || @poll
    
    if resource && resource.projekt.present?
      selected_projekt_id = resource.projekt.id
    elsif params[:projekt].present?
      selected_projekt_id = params[:projekt].to_i
    else
      selected_projekt_id = nil
    end

    (selected_projekt_id == current_projekt_id) && (can?(:select, @projekt_phase) || (current_user.administrator  && controller.controller_name == 'polls')) ?  'checked' : ''
  end

  def highlight_projekt_in_selector?(current_projekt)
    resource = @debate || @proposal

    if resource && resource.projekt.present?
      selected_projekt_id = resource.projekt.id
    elsif params[:projekt].present?
      selected_projekt_id = params[:projekt].to_i
    else
      selected_projekt_id = nil
    end

    if selected_projekt_id && selected_projekt = Projekt.find_by(id: selected_projekt_id)
      case resource.class.name
      when "Debate"
        phase_name = 'debate_phase'
        selected_projekt_projekt_phase = selected_projekt.send(phase_name)
      when "Proposal"
        phase_name = 'proposal_phase'
        selected_projekt_projekt_phase = selected_projekt.send(phase_name)
      end
    end

    if selected_projekt_projekt_phase && ( can?(:select, selected_projekt_projekt_phase) || (current_user.administrator && controller.controller_name == 'polls'))
      current_projekt.all_children_ids.push(current_projekt.id).include?(selected_projekt_id) ? 'highlighted' : '' 
    end
  end

  def show_projekt_group_in_selector?(projekts)
    resource = @debate || @proposal || @poll

    if resource && resource.projekt.present?
      selected_projekt_id = resource.projekt.id
    elsif params[:projekt].present?
      selected_projekt_id = params[:projekt].to_i
    else
      selected_projekt_id = nil
    end

    if selected_projekt_id
      (projekts.ids + projekts.map{ |projekt| projekt.all_children_ids }.flatten).include?(selected_projekt_id)
    end
  end
end
