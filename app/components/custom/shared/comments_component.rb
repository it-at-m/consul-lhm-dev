require_dependency Rails.root.join("app", "components", "shared", "comments_component").to_s

class Shared::CommentsComponent < ApplicationComponent
  private

    def cache_key
      [
        locale_and_user_status,
        current_order,
        commentable_cache_key(record),
        comment_tree.comments,
        comment_tree.comment_authors,
        record.comments_count,
        record_specific_keys
      ].flatten
    end

    def record_specific_keys
      keys = []
      add_phase_specific_keys(keys) if ["Proposal", "Debate"].include?(record.class.name) && record.projekt.present?
      add_poll_specific_keys(keys) if record.class.name == "Poll"
      add_projekt_page_specific_keys(keys) if record.class.name == "Projekt"
      keys
    end

    def add_phase_specific_keys(keys)
      keys.push(record.projekt_phase)
      keys.push(record.projekt_phase.geozone_restrictions)
      keys.push(helpers.change_of_current_state(record.projekt_phase.start_date, record.projekt_phase.end_date))
      keys.push(helpers.change_of_current_state(record.projekt.total_duration_start, record.projekt.total_duration_end))
    end

    def add_poll_specific_keys(keys)
      keys.push(record.geozones)
      keys.push(helpers.change_of_current_state(record.starts_at, record.ends_at))
      keys.push(record)
    end

    def add_projekt_page_specific_keys(keys)
      keys.push(record)
      keys.push(record.page)
      keys.push(record.projekt_settings)
      keys.push(record.comment_phase)
      keys.push(record.comment_phase.geozone_restrictions)
      keys.push(helpers.change_of_current_state(record.comment_phase.start_date, record.comment_phase.end_date))
    end

    def pagination_links
      if params[:current_tab_path].present?
        paginate comment_tree.root_comments, params: { action: params[:current_tab_path] }, remote: true
      else
        paginate comment_tree.root_comments, params: { anchor: "comments" }
      end
    end
end
