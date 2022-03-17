class Admin::CommentsController < Admin::BaseController
  def index
    @comments = Comment.sort_by_newest.page(params[:page])

    respond_to do |format|
      format.html
      format.csv do
        send_data Comments::CsvExporter.new(@comments.limit(20_000)).to_csv,
          filename: "comments.csv"
      end
    end
  end
end
