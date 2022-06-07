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

  def prepare_geo_affiliation_name(taggable)
    geo_affiliation_name = taggable.projekt.geozone_affiliated

    case geo_affiliation_name
    when 'entire_city'
      tag_name = t("custom.geozones.sidebar_filter.affiliations.entire_city_short")
    when 'only_geozones'
      taggable.projekt.geozone_affiliations.pluck(:name).join(', ')
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

  def generate_tag_div(taggable, tag_name, tag_type, url_params_string, tag_filter_class, active_class)
    tag_link = link_to tag_name, (taggables_path(taggable.class.name.underscore, '') + url_params_string), class: "#{tag_filter_class} projekt-tag-chip-icon projekt-tag-chip-geozone-#{tag_type} #{active_class}"
    tag.div(tag_link, class: "projekt-tag-chip")
  end
end
