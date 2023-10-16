require_dependency Rails.root.join("app", "controllers", "admin", "newsletters_controller").to_s

class Admin::NewslettersController < Admin::BaseController
  def new
    @newsletter = Newsletter.new
    @projekt = Projekt.find(params[:projekt_id]) if params[:projekt_id]

    if @projekt.present?
      @newsletter.subject = t("custom.newsletters.new_projekt.subject", title: @projekt.title)
      @newsletter.from = Setting["mailer_from_address"]
      @newsletter.segment_recipient = "newsletter_subscribers"
      @newsletter.body = newsletter_body
    end
  end

  private

    def newsletter_body
      body = ""
      body += "<h3>#{@projekt.title}</h3>" if @projekt.title
      body += "<p>#{@projekt.description}</p>" if @projekt.page.subtitle
      body += "<p><img src='#{url_for(@projekt.image.variant(:large))}'></p>" if @projekt.image

      if @projekt.total_duration_start.present?
        body += "<p><strong>#{t("custom.newsletters.new_projekt.total_duration_start")}:</strong> #{l(@projekt.total_duration_start, format: "%d. %B %Y")}</p>"
      end

      if @projekt.total_duration_end.present?
        body += "<p><strong>#{t("custom.newsletters.new_projekt.total_duration_end")}:</strong> #{t("custom.newsletters.new_projekt.total_duration_end_till")} #{l(@projekt.total_duration_end, format: "%d. %B %Y")}</p>"
      end

      body += "<p><strong>#{t("custom.newsletters.new_projekt.open_phases")}:</strong></p>"
      body += "<ul style='margin-bottom:30px;'>#{open_phases_for_body}</ul>"

      body += "<p style='margin-bottom:30px;'>"
      body += "<a href='#{page_url(@projekt.page.slug)}' style='background:#004a83;padding:0.75rem 1.5rem;color:#fff;border-radius:4px;margin-right:20px;display:inline-block;margin-bottom:15px;'>#{t("custom.newsletters.new_projekt.url")}</a>"
      body += "<a href='#{page_url(@projekt.page.slug)}#filter-subnav' style='background:#004a83;padding:0.75rem 1.5rem;color:#fff;border-radius:4px;display:inline-block;'>#{t("custom.newsletters.new_projekt.url_participate")}</a>"
      body += "</p>"

      body += "<p></p>"

      body
    end

    def open_phases_for_body
      @projekt.projekt_phases.where(projekt_phases: { active: true }).sorted.map do |phase|
        date_range = helpers.format_date_range(phase.start_date, phase.end_date)
        if date_range.present?
          "<li>#{phase.title} (#{helpers.format_date_range(phase.start_date, phase.end_date)})</li>"
        else
          "<li>#{phase.title}</li>"
        end
      end.join
    end
end
