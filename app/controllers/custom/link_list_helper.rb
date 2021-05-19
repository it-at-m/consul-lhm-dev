require_dependency Rails.root.join("app", "helpers", "link_list_helper").to_s

module LinkListHelper
  def link_list_sdg_goals(*links, **options)
    return "" if links.select(&:present?).empty?

    tag.ul(options) do
      safe_join(links.select(&:present?).map do |text, url, current = false, **link_options|

        goal_code = link_options[:data].present? ? link_options[:data][:code] : nil

        active_class = highlight_sdg_chip(goal_code) ? 'selected-goal' : 'unselected-goal'

        js_class = goal_code.class.name == "Integer" ? "js-sdg-custom-goal-filter" : "js-sdg-custom-target-filter-tag"

        tag.li(class: "#{js_class} #{active_class}") do
					link_to text, '#', link_options
        end
      end, "\n")
    end
  end

  def highlight_sdg_chip(goal_code)
    if goal_code.class.name == "Integer"
      return  @filtered_goals.nil? || @filtered_goals.include?(goal_code)
    end

    if goal_code.class.name == "String"
      return (@filtered_goals.nil? && @filtered_target.nil?) ||
        @filtered_target == goal_code ||
        @filtered_goals.include?(goal_code.split('.')[0].to_i)
    end
  end
end
