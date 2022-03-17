class Proposals::CsvExporter
  require "csv"
  include JsonExporter

  def initialize(proposals)
    @proposals = proposals
  end

  def to_csv
    CSV.generate(headers: true, col_sep: ";") do |csv|
      csv << headers

      @proposals.each do |proposal|
        csv << csv_values(proposal)
      end
    end
  end

  def model
    Proposal
  end

  private

    def headers
        # I18n.t("admin.proposals.index.list.id"),
      [
        "id",
        "title",
        "summary",
        "description",
        "project_name",
        "responsible_name",
        "author_username",
        "created_at",
        "hidden_at",
        "flags_count",
        "comments_count",
        "hot_score",
        "video_url",
        "retired_at",
        "retired_reason",
        "published_at",
        "community_id",
        "selected",
        "projekt_id",
        "latitude",
        "longitude"
      ]
    end

    def csv_values(proposal)
      [
        proposal.id.to_s,
        proposal.title,
        proposal.summary,
        proposal.description,
        proposal.projekt&.name,
        proposal.responsible_name,
        proposal.author.username,
        proposal.created_at,
        proposal.hidden_at,
        proposal.flags_count,
        proposal.comments_count,
        proposal.hot_score,
        proposal.video_url,
        proposal.retired_at,
        proposal.retired_reason,
        proposal.published_at,
        proposal.community_id,
        proposal.selected,
        proposal.projekt_id,
        proposal.map_location&.latitude,
        proposal.map_location&.longitude
      ]
    end
end
