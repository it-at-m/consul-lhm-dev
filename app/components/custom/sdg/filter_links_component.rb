require_dependency Rails.root.join("app", "components", "sdg", "filter_links_component").to_s

class SDG::FilterLinksComponent < ApplicationComponent
  delegate :link_list_sdg_goals, to: :helpers
end
