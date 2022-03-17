class DeficiencyReport::CsvExporter
  require "csv"
  include JsonExporter

  def initialize(deficiency_reports)
    @deficiency_reports = deficiency_reports
  end

  def to_csv
    CSV.generate(headers: true, col_sep: ";") do |csv|
      csv << headers

      @deficiency_reports.each do |deficiency_report|
        csv << csv_values(deficiency_report)
      end
    end
  end

  def model
    deficiency_report
  end

  private

    def headers
        # I18n.t("admin.deficiency_reports.index.list.id"),
      [
        "id",
        "title",
        "author_username",
        "summary",
        "official_answer",
        "comments_count",
        "created_at",
        "updated_at",
        "video_url",
        "category_name",
        "status_title",
        "officer_name",
        "officer_email",
        "latitude",
        "longitude"
      ]
    end

    def csv_values(deficiency_report)
      [
        deficiency_report.id.to_s,
        deficiency_report.title,
        deficiency_report.author.username,
        deficiency_report.summary,
        deficiency_report.official_answer,
        deficiency_report.comments_count,
        deficiency_report.created_at,
        deficiency_report.updated_at,
        deficiency_report.video_url,
        deficiency_report.category&.name,
        deficiency_report.status&.title,
        deficiency_report.officer&.name,
        deficiency_report.officer&.email,
        deficiency_report.map_location&.latitude,
        deficiency_report.map_location&.longitude
      ]
    end
end
