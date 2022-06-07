require_dependency Rails.root.join("app", "components", "shared", "tag_list_component").to_s

class Shared::TagListComponent < ApplicationComponent

  def render?
    taggable.tags_list.any?
  end

  private

    def taggables_path(taggable, tag_name)
      case taggable.class.name
      when "Legislation::Proposal"
        legislation_process_proposals_path(taggable.process, search: tag_name)
      else
        polymorphic_path(taggable.class, prepare_tags_for_params(tag_name))
      end
    end

    def prepare_tags_for_params(tag_name)
      return { tags: tag_name } if controller_name.in?([ 'welcome', 'pages' ])

      currently_selected_tags = params[:tags].present? ? params[:tags].split(',') : []
      currently_selected_tags.include?(tag_name) ? currently_selected_tags.delete(tag_name) : currently_selected_tags.push(tag_name)
      currently_selected_tags.join(',')

      params.merge({tags: currently_selected_tags.join(',')})
        .permit(:tags, :geozone_affiliation, :affiliated_geozones, :geozone_restriction, :restricted_geozones, :sdg_goals, :sdg_targets, filter_projekt_ids: [])
    end

    def tag_links
      taggable.tag_list_with_limit(limit).map do |tag|
        [
          sanitize(tag.name),
          taggables_path(taggable, tag.name),
          class: selected_tag?(tag.name)
        ]
      end
    end

    def selected_tag?(tag_name)
      return if params[:tags].blank?

      return 'selected' if tag_name.in?(params[:tags].split(','))
    end
end
