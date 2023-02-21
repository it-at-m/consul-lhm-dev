class Proposals::CsvExporter
  require "csv"
  include JsonExporter
  include ActionView::Helpers::SanitizeHelper

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

  private

    def headers
        # I18n.t("admin.proposals.index.list.id"),
      [
        "id",
        "title",
        "summary",
        "description",
        "project",
        "label(s)",
        "responsible_name",
        "author_username",
        "supports",
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
        "latitude",
        "longitude"
      ]
    end

    def csv_values(proposal)
      [
        proposal.id.to_s,
        proposal.title,
        proposal.summary,
        strip_tags(proposal.description),
        proposal.projekt&.name,
        proposal.projekt_labels&.map(&:name)&.join(" "),
        proposal.responsible_name,
        proposal.author.username,
        proposal.total_votes,
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
        geo_field(proposal.map_location&.latitude),
        geo_field(proposal.map_location&.longitude)
      ]
    end

    def geo_field(field)
      return nil if field.blank?

      "\"#{field}\""
    end
end
