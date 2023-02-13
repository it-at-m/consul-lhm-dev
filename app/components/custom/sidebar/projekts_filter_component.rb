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

  private

    def show_filter?
      return false if @current_projekt&.overview_page?

      if resources_name == "budget"
        return @current_projekt.present? && @current_projekt.children.joins(:budget).any?
      end

      @top_level_active_projekts.count > 1 ||

        (@top_level_active_projekts.count == 1 &&
          (@top_level_active_projekts.first.all_children_ids & @scoped_projekt_ids).any?) ||

        @top_level_archived_projekts.count > 1 ||

        (@top_level_archived_projekts.count == 1 &&
          (@top_level_archived_projekts.first.all_children_ids & @scoped_projekt_ids).any?)
    end

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
      if params[:current_tab_path]
        url_for(action: params[:current_tab_path],
                controller: "/pages",
                order: params[:order],
                projekt_label_ids: params[:projekt_label_ids],
                filter: params[:filter])
      else
        url_for(action: "index", controller: controller_name)
      end
    end

    def footer_tab_back_button_url
      if controller_name == "pages" &&
          params[:current_tab_path].present? &&
          !helpers.request.path.starts_with?("/projekts")

        url_for_footer_tab_back_button(page_id: params[:id],
                                       pagination_page: params[:page],
                                       current_tab_path: params[:current_tab_path],
                                       filter: params[:filter],
                                       order: params[:order],
                                       projekt_label_ids: params[:projekt_label_ids])
      else
        "empty"
      end
    end

    def local_form?
      controller_name != "pages"
    end

    def cache_key
      [
        Projekt.all,
        ProjektSetting.where("key LIKE ?", "projekt_feature.main.activate"),
        ProjektSetting.where("key LIKE ?", "%show_in_sidebar_filter%"),
        ProjektSetting.find_by(projekt: @current_projekt, key: "projekt_custom_feature.default_footer_tab"),
        params[:filter_projekt_ids],
        params[:tags],
        params[:projekts],
        params[:geozone_affiliation],
        params[:affiliated_geozones],
        params[:geozone_restriction],
        params[:restricted_geozones],
        params[:my_posts_filter],
        controller_name,
        action_name
      ].flatten
    end
end
