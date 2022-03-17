class Debates::CsvExporter
  require "csv"
  include JsonExporter

  def initialize(debates)
    @debates = debates
  end

  def to_csv
    CSV.generate(headers: true, col_sep: ";") do |csv|
      csv << headers

      @debates.each do |debate|
        csv << csv_values(debate)
      end
    end
  end

  def model
    Proposal
  end

  private

    def headers
      [
        "id",
        "title",
        "description",
        "project",
        "category",
        "author",
        "projekt_id",
        "created_at",
        "updated_at",
        "visit_id",
        "hidden_at",
        "flags_count",
        "ignored_flag_at",
        "cached_votes_total",
        "cached_votes_up",
        "cached_votes_down",
        "comments_count",
        "confirmed_hide_at",
        "cached_anonymous_votes_total",
        "cached_votes_score",
        "hot_score",
        "confidence_score",
        "geozone_id",
        "tsv",
        "featured_at"
      ]
    end

    def csv_values(debate)
      [
        debate.id,
        debate.title,
        debate.description,
        debate.projekt&.name,
        debate.tag_list,
        debate.author.username,
        debate.projekt_id,
        debate.created_at,
        debate.updated_at,
        debate.visit_id,
        debate.hidden_at,
        debate.flags_count,
        debate.ignored_flag_at,
        debate.cached_votes_total,
        debate.cached_votes_up,
        debate.cached_votes_down,
        debate.comments_count,
        debate.confirmed_hide_at,
        debate.cached_anonymous_votes_total,
        debate.cached_votes_score,
        debate.hot_score,
        debate.confidence_score,
        debate.geozone_id,
        debate.featured_at
      ]
    end
end
