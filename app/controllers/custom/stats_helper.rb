require_dependency Rails.root.join("app", "helpers", "stats_helper").to_s

module StatsHelper
  def number_with_info_tags(number, text, html_class: "", show_percentage_values_only: false)
    tag.p class: "number-with-info #{html_class}".strip do
      tag.span class: "content" do
        if show_percentage_values_only
          tag.span(text, class: "info")
        else
          tag.span(number, class: "number") + tag.span(text, class: "info")
        end
      end
    end
  end
end
