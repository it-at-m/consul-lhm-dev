require_dependency Rails.root.join("app", "controllers", "admin", "newsletters_controller").to_s

class Admin::NewslettersController < Admin::BaseController
  def new
    @newsletter = Newsletter.new
    @projekt = Projekt.find(params[:projekt_id]) if params[:projekt_id]

    if @projekt.present?
      @newsletter.segment_recipient = "newsletter_subscribers"
      @newsletter.body = newsletter_body
    end
  end

  private

    def newsletter_body
      body = ""
      body += "<h1>#{@projekt.title}</h1>" if @projekt.title
      body += "<p>#{@projekt.description}</p>" if @projekt.description
      body += "<p><img src='#{url_for(@projekt.image.variant(:large))}'></p>" if @projekt.image

      body += "<p>#{t("custom.newsletters.new_projekt.total_duration_start")}: #{l(@projekt.total_duration_start, format: "%d. %B %Y")}</p>"
      body += "<p>#{t("custom.newsletters.new_projekt.total_duration_end")}: #{l(@projekt.total_duration_end, format: "%d. %B %Y")}</p>"

      body += "<p>#{t("custom.newsletters.new_projekt.open_phases")}:</p>"
      body += "<ul>#{open_phases_for_body}</ul>"

      body += "<p><a href=#{@projekt.page.url}>#{t("custom.newsletters.new_projekt.url")}</a></p>"

      body
    end

    def open_phases_for_body
      @projekt.projekt_phases.sorted.map do |phase|
        "<li>#{phase.title}</li>"
      end.join
    end
end
