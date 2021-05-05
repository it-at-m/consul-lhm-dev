require_dependency Rails.root.join("app", "helpers", "proposals_helper").to_s

module ProposalsHelper

  def all_proposal_map_locations
    proposals_for_map = Proposal.not_archived.published

    if params[:tags].present?
      proposals_for_map = proposals_for_map.tagged_with(params[:tags].split(","), all: true)
    end

    if params[:projekts].present?
      proposals_for_map = proposals_for_map.where(projekt_id: params[:projekts].split(',')).distinct
    end

    ids = proposals_for_map.pluck(:id).uniq

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

  def withdraw_proposal_support_on?
    Setting["extended_feature.enable_proposal_support_withdrawal"]
  end
end
