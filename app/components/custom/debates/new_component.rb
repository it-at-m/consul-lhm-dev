require_dependency Rails.root.join("app", "components", "debates", "new_component").to_s

class Debates::NewComponent < ApplicationComponent

  private

  def debates_back_link_path
    if params[:origin] == 'projekt'
      projekt = Projekt.find(params[:projekt])
      page = projekt.page
      debate_phase_id = projekt.debate_phase.id

      link_to "/#{page.slug}?selected_phase_id=#{debate_phase_id}", class: "back" do
        tag.span(class: "icon-angle-left") + t("shared.back")
      end

    else
      back_link_to debates_path

    end
  end
end
