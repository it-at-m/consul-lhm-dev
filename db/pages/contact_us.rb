if SiteCustomization::Page.find_by(slug: "contact_us").nil?
  page = SiteCustomization::Page.new(slug: "contact_us", status: "published")
  page.print_content_flag = true
  page.title = I18n.t("custom.pages.contact_us.title")
  page.save!
end
