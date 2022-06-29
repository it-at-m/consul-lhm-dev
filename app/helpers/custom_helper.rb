module CustomHelper
  def tag_kind_name(kind)
    if kind == 'category'
      t('admin.tags.logic.category')
    end
  end

  def tag_count_label(tags)
    label = t('admin.tags.index.topic')
    label = label.pluralize if tags.count > 1
    label = label.downcase unless locale == :de
    label
  end

  def svg_tag(icon_name, options={})
    file = File.read(Rails.root.join('app', 'assets', 'images', 'custom', "#{icon_name}.svg"))
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'

    options.each {|attr, value| svg[attr.to_s] = value}

    doc.to_html.html_safe
  end

  def all_projekt_proposals_map_locations(projekt)
    proposals_for_map = projekt.proposals.not_archived.published

    ids = proposals_for_map.pluck(:id).uniq

    MapLocation.where(proposal_id: ids).map(&:json_data)
  end

  def projekt_legislation_process_footer_path(current_projekt, draft_version, section: 'text', anchor: 'footer-content', params: {})
    current_projekt.page.url + "?text_draft_version_id=#{draft_version.id}&selected_phase_id=#{current_projekt.legislation_process_phase.id}" + "&section=#{section}&#{params.to_query}" + "##{anchor}"
  end

  def legislation_process_tabs(process)
    {
      "info"           => edit_admin_legislation_process_path(process),
      "draft_versions" => admin_legislation_process_draft_versions_path(process),
    }
  end
end
