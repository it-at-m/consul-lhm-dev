class Poll::CsvExporter
  require "csv"
  include JsonExporter

  def initialize(polls)
    @polls = polls
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers

      @polls.each do |poll|
        csv << csv_values(poll)
      end
    end
  end

  private

    def headers
      [
        "starts_at",
        "ends_at",
        "published",
        "geozone_restricted",
        "comments_count",
        "author_username",
        "hidden_at",
        "slug",
        "created_at",
        "updated_at",
        "budget_id",
        "related_type",
        "related_id",
        "projekt_id",
        "show_open_answer_author_name",
        "show_summary_instead_of_questions",
      ]
    end

    def csv_values(poll)
      [
        poll.starts_at,
        poll.ends_at,
        poll.published,
        poll.geozone_restricted,
        poll.comments_count,
        poll.author&.username,
        poll.hidden_at,
        poll.slug,
        poll.created_at,
        poll.updated_at,
        poll.budget_id,
        poll.related_type,
        poll.related_id,
        poll.projekt_id,
        poll.show_open_answer_author_name,
        poll.show_summary_instead_of_questions
      ]
    end
end
