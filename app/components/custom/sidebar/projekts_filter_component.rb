class Sidebar::ProjektsFilterComponent < ApplicationComponent
  delegate :projekt_filter_resources_name, :show_archived_projekts_in_sidebar?, to: :helpers

  def initialize(
    top_level_active_projekts:,
    top_level_archived_projekts:,
    scoped_projekt_ids:,
    all_resources:,
    current_tab_phase: nil,
    current_projekt: nil
  )
    @top_level_active_projekts = top_level_active_projekts
    @top_level_archived_projekts = top_level_archived_projekts
    @scoped_projekt_ids = scoped_projekt_ids
    @all_resources = all_resources
    @current_tab_phase = current_tab_phase
    @current_projekt = current_projekt
  end

    def show_filter?
      if resources_name == "budget"
        return @current_projekt.present? && @current_projekt.children.joins(budget_phases: :budget).any?
      end

      @top_level_active_projekts.count > 1 ||

        (@top_level_active_projekts.count == 1 &&
          (@top_level_active_projekts.first.all_children_ids).any?) ||

        @top_level_archived_projekts.count > 1 ||

        (@top_level_archived_projekts.count == 1 &&
          (@top_level_archived_projekts.first.all_children_ids & @scoped_projekt_ids).any?)
    end

  private

    def show_archived_projekts_in_sidebar?
      true
    end

    def resources_name
      projekt_filter_resources_name
    end

    def resource_name_js
      if @current_tab_phase && @current_projekt
        "footer#{@current_projekt.id}#{@current_tab_phase.name.capitalize}"
      else
        controller_name
      end
    end

    def projekts_to_toggle_js
      if @current_projekt
        @current_projekt
          .all_children_ids.unshift(@current_projekt.id)
          .unshift(@current_projekt.all_parent_ids)
          .join(",")
      else
        ""
      end
    end

    def form_path
      if @current_tab_phase.present? && @current_projekt.present?
        projekt_phase_footer_tab_page_path(@current_projekt.page, @current_tab_phase,
                                            page: params[:page] || 1,
                                            order: params[:order],
                                            projekt_label_ids: params[:projekt_label_ids],
                                            filter: params[:filter]
                                          )
      else
        url_for(action: "index", controller: controller_name)
      end
    end

    def footer_tab_back_button_url
      if controller_name == "pages" &&
          params[:projekt_phase_id].present? &&
          !helpers.request.path.starts_with?("/projekts")

        url_to_footer_tab
      else
        "empty"
      end
    end

    def local_form?
      controller_name != "pages"
    end
end
