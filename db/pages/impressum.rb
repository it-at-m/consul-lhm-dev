if SiteCustomization::Page.find_by(slug: "impressum").nil?
  page = SiteCustomization::Page.new(slug: "impressum", status: "published")
  page.print_content_flag = true
  page.title = I18n.t("custom.pages.impressum.title")
  page.save!
end
