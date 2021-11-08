require_dependency Rails.root.join("app", "helpers", "content_blocks_helper").to_s
module ContentBlocksHelper

  def render_custom_block(key)
    block = SiteCustomization::ContentBlock.custom_block_for(key, I18n.locale)
    if current_user && current_user.administrator?
      edit_link = link_to '', edit_admin_site_customization_content_block_path(block, return_to: request.path), class: 'edit-custom-block-link'
    end
    res = block&.body || ""
    if edit_link
      res << edit_link ? "<br>#{edit_link}" : ""
    end
    AdminWYSIWYGSanitizer.new.sanitize(res)
  end
end
