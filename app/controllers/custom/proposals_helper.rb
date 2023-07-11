require_dependency Rails.root.join("app", "helpers", "proposals_helper").to_s

module ProposalsHelper

  def all_proposal_map_locations(proposals_for_map)
    ids = proposals_for_map.except(:limit, :offset, :order).ids.uniq

    MapLocation.where(proposal_id: ids).map do |map_location|
      map_location.shape_json_data.presence || map_location.json_data
    end
  end

  def json_data
    proposal = Proposal.find(params[:id])

    labels = []
    proposal.projekt_labels.each do |label|
      label = {
        name: label.name,
        icon: label.icon
      }
      labels.push(label)
    end

    sentiment = {}
    if proposal.sentiment.present?
      sentiment["name"] = proposal.sentiment.name
      sentiment["background-color"] = proposal.sentiment.color
      sentiment["color"] = helpers.pick_text_color(proposal.sentiment.color)
    end

    image_url = proposal.image.present? ? url_for(proposal.image.variant(:popup)) : nil

    data = {
      proposal_id: proposal.id,
      proposal_title: proposal.title,
      image_url: image_url,
      labels: labels,
      sentiment: sentiment
    }.to_json

    respond_to do |format|
      format.json { render json: data }
    end
  end

  def label_error_class?(field)
    return 'is-invalid-label' if @proposal.errors.any? && @proposal.errors[field].present?
    ""
  end

  def error_text(field)
    return @proposal.errors[:description].join(', ') if @proposal.errors.any? && @proposal.errors[field].present?
    ""
  end

  def default_active_proposal_footer_tab?(tab)
    return true if tab == "comments" && projekt_phase_feature?(@proposal.projekt_phase, "resource.show_comments")

    return true if tab == "notifications" && projekt_phase_feature?(@proposal.projekt_phase, "resource.enable_proposal_notifications_tab") &&
      !projekt_phase_feature?(@proposal.projekt_phase, "resource.show_comments")

    tab == "milestones" && projekt_phase_feature?(@proposal.projekt_phase, "resource.enable_proposal_milestones_tab") &&
      !projekt_phase_feature?(@proposal.projekt_phase, "resource.show_comments") &&
      !projekt_phase_feature?(@proposal.projekt_phase, "resource.enable_proposal_notifications_tab")
  end
end
