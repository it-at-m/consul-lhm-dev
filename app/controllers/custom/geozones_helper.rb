require_dependency Rails.root.join("app", "helpers", "geozones_helper").to_s

module GeozonesHelper

  def prepare_geo_restriction_tag(taggable, resource_name, tag_filter_class)
    geozone_restriction = params[:geozone_restriction]
    selected_geozones = (params[:geozones] || []).split(',')
    geo_restriction_name = taggable.send("#{@resource_name}_phase").geozone_restricted

    tag_name = t("custom.geozones.sidebar_filter.#{geo_restriction_name}" )
    url_params_string = "&geozone_restriction=#{geo_restriction_name}"
    active_class = ''

    case geo_restriction_name
    when 'all_resources'
      generate_tag_div(taggable, tag_name, url_params_string, tag_filter_class, active_class)
    when 'no_restriction'
      active_class = (geo_restriction_name == geozone_restriction) ? 'filtered-projekt' : ''
      generate_tag_div(taggable, tag_name, url_params_string, tag_filter_class, active_class)
    when 'only_citizens'
      active_class = (geo_restriction_name == geozone_restriction) ? 'filtered-projekt' : ''
      generate_tag_div(taggable, tag_name, url_params_string, tag_filter_class, active_class)
    when 'only_geozones'
      geo_tags = ''
      taggable.geozones.each do |geozone|
        active_class = (selected_geozones.any? && selected_geozones.include?(geozone.id.to_s)) ? 'filtered-projekt' : ''
        tag_name = geozone.name
        url_params_string = "&geozone_restriction=#{geo_restriction_name}&geozones=#{geozone.id}"
        geo_tags += generate_tag_div(taggable, tag_name, url_params_string, tag_filter_class, active_class)
      end
      geo_tags.html_safe
    end
  end

  def prepare_geo_restriction_tag_for_polls(taggable, tag_filter_class)
    geozone_restriction = params[:geozone_restriction]
    selected_geozones = (params[:geozones] || []).split(',')


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


    tag_name = t("custom.geozones.sidebar_filter.#{geo_restriction_name}" )
    url_params_string = "&geozone_restriction=#{geo_restriction_name}"
    active_class = ''

    case geo_restriction_name
    when 'all_resources'
      generate_tag_div(taggable, tag_name, url_params_string, tag_filter_class, active_class)
    when 'no_restriction'
      active_class = (geo_restriction_name == geozone_restriction) ? 'filtered-projekt' : ''
      generate_tag_div(taggable, tag_name, url_params_string, tag_filter_class, active_class)
    when 'only_citizens'
      active_class = (geo_restriction_name == geozone_restriction) ? 'filtered-projekt' : ''
      generate_tag_div(taggable, tag_name, url_params_string, tag_filter_class, active_class)
    when 'only_geozones'
      geo_tags = ''
      taggable.geozones.each do |geozone|
        active_class = (selected_geozones.any? && selected_geozones.include?(geozone.id.to_s)) ? 'filtered-projekt' : ''
        tag_name = geozone.name
        url_params_string = "&geozone_restriction=#{geo_restriction_name}&geozones=#{geozone.id}"
        geo_tags += generate_tag_div(taggable, tag_name, url_params_string, tag_filter_class, active_class)
      end
      geo_tags.html_safe
    end
  end

  def generate_tag_div(taggable, tag_name, url_params_string, tag_filter_class, active_class)
    tag_link = link_to tag_name, (taggables_path(taggable.class.name.underscore, '') + url_params_string), class: "#{tag_filter_class} projekt-tag-chip-icon projekt-tag-chip-geozone"
    tag.div(tag_link, class: "projekt-tag-chip #{active_class}")
  end
end
