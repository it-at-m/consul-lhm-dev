require_dependency Rails.root.join("app", "components", "proposals", "new_component").to_s

class Proposals::NewComponent < ApplicationComponent

  def initialize(proposal, selected_projekt)
    @proposal = proposal
    @selected_projekt = selected_projekt
  end

  private

    def proposals_back_link_path
      if params[:origin] == "projekt" && params[:projekt_phase_id].present?

        link_to url_to_footer_tab, class: "back" do
          tag.span(class: "icon-angle-left") + t("shared.back")
        end

      else
        back_link_to proposals_path

      end
    end
end
