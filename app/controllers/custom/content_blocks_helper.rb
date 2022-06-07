require_dependency Rails.root.join("app", "helpers", "content_blocks_helper").to_s

module ContentBlocksHelper

  def render_custom_block(key)
    block = SiteCustomization::ContentBlock.custom_block_for(key, I18n.locale)
    block_body = block&.body || ""

    if current_user && current_user.administrator?
      edit_link = link_to('<i class="fas fa-edit"></i>'.html_safe, edit_admin_site_customization_content_block_path(block, return_to: request.path) )
    end

    if block_body.present? && current_user && current_user.email.in?(@partner_emails)
      copy_link = link_to '<i class="fas fa-code"></i>'.html_safe, '#', class: 'js-copy-source-button', style: "#{'margin-left:10px' if edit_link.present?}", data: { target: '#home_page_1' }
    end

    res = "<div id=#{key}>#{block_body}</div>"

    if edit_link || copy_link
      res << "<div class='custom-block-controls margin-top'>"
        res << edit_link if edit_link.present?
        res << copy_link if copy_link.present?
      res << "</div>"
    end

    AdminWYSIWYGSanitizer.new.sanitize(res)
  end
end
