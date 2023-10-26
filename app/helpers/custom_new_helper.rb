module CustomNewHelper
  def topbar_image_path
    image_name =
      if extended_feature?('general.use_white_top_navigation_text')
        "logo_header_white_new.png"
      else
        "logo_header_new.png"
      end

    image = SiteCustomization::Image.image_for(image_name)

    if image
      polymorphic_path(image)
    else
      image_name
    end
  end

  def resources_back_link(fallback_path:)
    if params[:origin] == "projekt" && params[:projekt_phase_id].present?
      link_to(url_to_footer_tab, class: "back") do
        tag.span(class: "icon-angle-left") + t("shared.back")
      end
    else
      back_path =
        if session[:back_path].present? && session[:back_path] != request.fullpath
          session[:back_path]
        else
          fallback_path
        end

      back_link_to(back_path)
    end
  end

  def custom_new_design_body_class
    Setting.new_design_enabled? ? 'custom-new-design' : ''
  end

  def sentiment_color_style(sentiment)
    if sentiment.present?
      "background-color:#{sentiment.color};color: #{pick_text_color(sentiment.color)}"
    end
  end

  def setting
    Setting.all_settings_hash
  end
end
