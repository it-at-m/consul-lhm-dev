require_dependency Rails.root.join("app", "helpers", "geozones_helper").to_s

module GeozonesHelper
  def prepare_geo_restriction_name(taggable)
    phase_name = "#{taggable.class.name.downcase}_phase"

    return nil unless taggable.respond_to?(phase_name)

    geo_restriction_name = taggable.send(phase_name).geozone_restricted

    case geo_restriction_name
    when 'only_citizens'
      t("custom.geozones.sidebar_filter.restrictions.#{geo_restriction_name}" )
    when 'only_geozones'
      taggable.geozone_restrictions.pluck(:name).join(', ')
    end
  end

  def prepare_geo_restriction_tag(taggable, resource_name, tag_filter_class)
    geo_restriction_name = taggable.send("#{resource_name}_phase").geozone_restricted
    tag_name = t("custom.geozones.sidebar_filter.restrictions.#{geo_restriction_name}" )
    tag_type = 'restriction'

    url_params_string = "&geozone_restriction=#{geo_restriction_name}"
    active_class = ''

    case geo_restriction_name
    when 'only_citizens'
      active_class = (geo_restriction_name == @selected_geozone_restriction) ? 'filtered-projekt' : ''
      generate_tag_div(taggable, tag_name, tag_type, url_params_string, tag_filter_class, active_class)
    when 'only_geozones'
      geo_tag_links = []
      taggable.geozone_restrictions.each do |geozone|
        active_class = (@restricted_geozones.any? && @restricted_geozones.include?(geozone.id)) ? 'filtered-projekt' : ''
        icon_class = geo_tag_links.empty? ? "projekt-tag-chip-icon projekt-tag-chip-geozone-#{tag_type}" : ""
        tag_name = geozone.name
        url_params_string = "&geozone_restriction=#{geo_restriction_name}&restricted_geozones=#{geozone.id}"
        link_to_geozone = link_to(tag_name, (taggables_path(taggable.class.name.underscore, '') + url_params_string), class: "#{tag_filter_class} #{icon_class} #{active_class}").html_safe
        geo_tag_links.push (link_to_geozone)
      end

      tag.div(safe_join(geo_tag_links, ', '), class: "projekt-tag-chip")
    end
  end

  def prepare_geo_affiliation_name(taggable)
    geo_affiliation_name = taggable.projekt.geozone_affiliated

    case geo_affiliation_name
    when 'entire_city'
      tag_name = t("custom.geozones.sidebar_filter.affiliations.entire_city_short")
    when 'only_geozones'
      taggable.projekt.geozone_affiliations.pluck(:name).join(', ')
    end
  end

  def prepare_geo_affiliation_tag(taggable, resource_name, tag_filter_class)
    geo_affiliation_name = taggable.projekt.geozone_affiliated
    tag_name = t("custom.geozones.sidebar_filter.affiliations.#{geo_affiliation_name}" )
    tag_type = 'affiliation'

    url_params_string = "&geozone_affiliation=#{geo_affiliation_name}"
    active_class = ''

    case geo_affiliation_name
    when 'entire_city'
      tag_name = t("custom.geozones.sidebar_filter.affiliations.entire_city_short")
      active_class = (geo_affiliation_name == @selected_geozone_affiliation) ? 'filtered-projekt' : ''
      generate_tag_div(taggable, tag_name, tag_type, url_params_string, tag_filter_class, active_class)
    when 'only_geozones'
      geo_tag_links = []
      taggable.projekt.geozone_affiliations.each do |geozone|
        active_class = (@affiliated_geozones.any? && @affiliated_geozones.include?(geozone.id)) ? 'filtered-projekt' : ''
        icon_class = geo_tag_links.empty? ? "projekt-tag-chip-icon projekt-tag-chip-geozone-#{tag_type}" : ""
        tag_name = geozone.name
        url_params_string = "&geozone_affiliation=#{geo_affiliation_name}&affiliated_geozones=#{geozone.id}"
        link_to_geozone = link_to(tag_name, (taggables_path(taggable.class.name.underscore, '') + url_params_string), class: "#{tag_filter_class} #{icon_class} #{active_class}").html_safe
        geo_tag_links.push (link_to_geozone)
      end

      tag.div(safe_join(geo_tag_links, ', '), class: "projekt-tag-chip")
    end
  end

  def prepare_geo_restriction_name_for_polls(taggable)
    return nil unless taggable.class.name == 'Poll'

    if taggable.geozone_restricted && taggable.geozones.any?
      taggable.geozones.pluck(:name).join(', ')
    elsif taggable.geozone_restricted
      t("custom.geozones.sidebar_filter.restrictions.only_citizens" )
    end
  end

  def prepare_geo_restriction_tag_for_polls(taggable, tag_filter_class)
    geozone_restriction = params[:geozone_restriction]
    selected_geozones = (params[:restricted_geozones] || []).split(',')


    case taggable.geozone_restricted
    when true
      if taggable.geozones.any?
        geo_restriction_name = 'only_geozones'
      else
        geo_restriction_name = 'only_citizens'
      end
    when false
      geo_restriction_name = 'no_restriction'
    end


    tag_name = t("custom.geozones.sidebar_filter.restrictions.#{geo_restriction_name}" )
    tag_type = 'restriction'
    url_params_string = "&geozone_restriction=#{geo_restriction_name}"
    active_class = ''

    case geo_restriction_name
    when 'only_citizens'
      active_class = (geo_restriction_name == geozone_restriction) ? 'filtered-projekt' : ''
      generate_tag_div(taggable, tag_name, tag_type, url_params_string, tag_filter_class, active_class)
    when 'only_geozones'
      geo_tag_links = []
      taggable.geozones.each do |geozone|
        active_class = (selected_geozones.any? && selected_geozones.include?(geozone.id.to_s)) ? 'filtered-projekt' : ''
        icon_class = geo_tag_links.empty? ? "projekt-tag-chip-icon projekt-tag-chip-geozone-#{tag_type}" : ""
        tag_name = geozone.name
        url_params_string = "&geozone_restriction=#{geo_restriction_name}&restricted_geozones=#{geozone.id}"
        link_to_geozone = link_to(tag_name, (taggables_path(taggable.class.name.underscore, '') + url_params_string), class: "#{tag_filter_class} #{icon_class} #{active_class}").html_safe
        geo_tag_links.push (link_to_geozone)
      end

      tag.div(safe_join(geo_tag_links, ', '), class: "projekt-tag-chip")
    end
  end

  def generate_tag_div(taggable, tag_name, tag_type, url_params_string, tag_filter_class, active_class)
    tag_link = link_to tag_name, (taggables_path(taggable.class.name.underscore, '') + url_params_string), class: "#{tag_filter_class} projekt-tag-chip-icon projekt-tag-chip-geozone-#{tag_type} #{active_class}"
    tag.div(tag_link, class: "projekt-tag-chip")
  end
end
