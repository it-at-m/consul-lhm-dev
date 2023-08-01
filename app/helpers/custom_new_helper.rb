module CustomNewHelper
  def topbar_image_path
    image_name =
      if Setting.enabled?("extended_feature.general.use_white_top_navigation_text")
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

  def custom_new_design_body_class
    Setting.new_design_enabled? ? 'custom-new-design' : ''
  end
end
