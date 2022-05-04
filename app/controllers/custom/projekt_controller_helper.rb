module ProjektControllerHelper

  def get_highest_unique_parent_projekt_id(selected_projekts_ids)
    selected_parent_projekt_id = nil
    top_level_active_projekt_ids = Projekt.top_level.activated.ids
    selected_projekts_ids = selected_projekts_ids.select{ |id| top_level_active_projekt_ids.include? Projekt.find_by(id: id).top_parent.id }
    return nil if selected_projekts_ids.empty?

    selected_projekts = Projekt.where(id: selected_projekts_ids)
    highest_level_selected_projekts = selected_projekts.sort { |a, b| a.level <=> b.level }.group_by(&:level).first[1]

    if highest_level_selected_projekts.size == 1
      highest_level_selected_projekt = highest_level_selected_projekts.first
    end

    if highest_level_selected_projekt && (selected_projekts_ids.map(&:to_i) - highest_level_selected_projekt.all_children_ids.push(highest_level_selected_projekt.id) )
      selected_parent_projekt_id = highest_level_selected_projekts.first.id
    end

    selected_parent_projekt_id
  end

  def all_projekts_map_locations(projekts_for_map)
    # ids = projekts_for_map.except(:limit, :offset, :order).pluck(:id).uniq
    ids = projekts_for_map.map(&:id).uniq

    MapLocation.where(projekt_id: ids).map(&:json_data)
  end
end
