require_dependency Rails.root.join("app", "controllers", "dashboard", "polls_controller").to_s

class Dashboard::PollsController < Dashboard::BaseController
  def create
    @poll = Poll.new(poll_params.merge(author: current_user, related: proposal))
    @poll.projekt_phase_id = proposal.projekt_phase_id

    if @poll.save
      redirect_to proposal_dashboard_polls_path(proposal), notice: t("flash.actions.create.poll")
    else
      render :new
    end
  end

  def update
    respond_to do |format|
      if poll.update(poll_params)
        format.html do
          redirect_to proposal_dashboard_polls_path(proposal),
                      notice: t("flash.actions.update.poll")
        end

        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: poll.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def allowed_params
    [:name, :starts_at, :ends_at, :description, :results_enabled, :projekt_phase_id,
      questions_attributes: question_attributes]
  end
end
