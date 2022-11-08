require_dependency Rails.root.join("app", "helpers", "proposals_helper").to_s

module ProposalsHelper

  def all_proposal_map_locations(proposals_for_map)
    ids = proposals_for_map.except(:limit, :offset, :order).pluck(:id).uniq

    MapLocation.where(proposal_id: ids).map(&:json_data)
  end

  def json_data
    proposal = Proposal.find(params[:id])
    data = {
      proposal_id: proposal.id,
      proposal_title: proposal.title
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
    return true if tab == "comments" && projekt_feature?(@proposal&.projekt, 'proposals.show_comments')

    return true if tab == "notifications" && projekt_feature?(@proposal&.projekt, 'proposals.enable_proposal_notifications_tab') &&
                     !projekt_feature?(@proposal&.projekt, 'proposals.show_comments')

    tab == "milestones" && projekt_feature?(@proposal&.projekt, 'proposals.enable_proposal_milestones_tab') &&
      !projekt_feature?(@proposal&.projekt, 'proposals.show_comments') &&
      !projekt_feature?(@proposal&.projekt, 'proposals.enable_proposal_notifications_tab')
  end
end
