require_dependency Rails.root.join("app", "controllers", "legislation", "annotations_controller").to_s

class Legislation::AnnotationsController < Legislation::BaseController
  def comments
    @annotation = Legislation::Annotation.find(params[:annotation_id])
    @draft_version = @annotation.draft_version
    @current_projekt = @draft_version.process.projekt
    @comment = @annotation.comments.new
  end
end
