require_dependency Rails.root.join("app", "helpers", "content_blocks_helper").to_s

module ContentBlocksHelper
  def render_custom_block(key, custom_prefix: nil, default_content: nil)
    block = SiteCustomization::ContentBlock.custom_block_for(key, I18n.locale)
    block_body = block&.body.presence || default_content || ""

    if custom_prefix
      block_body = "#{custom_prefix} #{block_body}"
    end

    if current_user &&
       (current_user.administrator? || (@custom_page&.projekt && current_user&.projekt_manager?(@custom_page&.projekt)))

      edit_link = link_to('<i class="fas fa-edit"></i>'.html_safe, edit_admin_site_customization_content_block_path(block, return_to: request.path) )
    end

    if block_body.present? && current_user && current_user.email.in?(@partner_emails)
      copy_link = link_to '<i class="fas fa-code"></i>'.html_safe, '#', class: 'js-copy-source-button', style: "#{'margin-left:10px' if edit_link.present?}", data: { target: key }
    end

    res = "<div id=#{key} class=#{ 'custom-content-block-body' if block_body.present? }>#{block_body}</div>"

    if edit_link || copy_link
      res << "<div class='custom-content-block-controls'>"
        res << edit_link if edit_link.present?
        res << copy_link if copy_link.present?
      res << "</div>"
    end

    AdminWYSIWYGSanitizer.new.sanitize(res)
  end

  def render_custom_content_block?(key)
    content_block = SiteCustomization::ContentBlock.custom_block_for(key, I18n.locale)

    (
      (current_user.present? && current_user.administrator?) ||
      content_block.present? && content_block.body.present?
    )
  end


  def render_custom_projekt_content_block?(key, projekt)
    content_block = SiteCustomization::ContentBlock.custom_block_for(key, I18n.locale)

    current_user.present? && (
      (current_user.administrator? || (
          current_user.projekt_manager? && can?(:edit, @projekt)
        )
      ) || content_block.present?
    )
  end

  def current_user_can_edit_content_block?
    (
      current_user &&
      (
        current_user.administrator? ||
        current_user&.projekt_manager?(@custom_page&.projekt)
      )
    )
  end
end
