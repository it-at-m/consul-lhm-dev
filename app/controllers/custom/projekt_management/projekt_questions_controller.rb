class ProjektManagement::ProjektQuestionsController < ProjektManagement::BaseController
  def new
    @projekt = Projekt.find(params[:projekt_id])
    @projekt_question = ProjektQuestion.new(projekt_id: @projekt.id)
    @namespace = params[:controller].split("/").first

    authorize! :new, @projekt_question if @namespace == "projekt_management"

    render "admin/projekts/edit/projekt_questions/new"
  end

  def edit
    @projekt = Projekt.find(params[:projekt_id])
    @projekt_question = ProjektQuestion.find(params[:id])
    @namespace = params[:controller].split("/").first

    authorize! :new, @projekt_question if @namespace == "projekt_management"

    render "admin/projekts/edit/projekt_questions/edit"
  end
end
