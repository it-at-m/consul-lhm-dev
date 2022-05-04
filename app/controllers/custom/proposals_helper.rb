require_dependency Rails.root.join("app", "helpers", "proposals_helper").to_s

module ProposalsHelper

  def all_proposal_map_locations(proposals_for_map)
    ids = proposals_for_map.except(:limit, :offset, :order).pluck(:id).uniq

    MapLocation.where(proposal_id: ids).map(&:json_data)
  end

  def proposal_settings_fingerprints
    Setting.all.group_by(&:type)["extended_feature.proposals"].map{ |s| s.value == "active" ? 1 : 0 }.join()
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
end
