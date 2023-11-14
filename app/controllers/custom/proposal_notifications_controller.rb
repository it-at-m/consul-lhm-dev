class ProposalNotificationsController < ApplicationController
  load_and_authorize_resource except: [:new]

  def new
    @proposal = Proposal.find(params[:proposal_id])
    @notification = ProposalNotification.new(proposal_id: @proposal.id)
    authorize! :new, @notification
  end

  def create
    @proposal_notification = ProposalNotification.new(proposal_notification_params)
    @proposal = Proposal.find(proposal_notification_params[:proposal_id])
    if @proposal_notification.save
      @proposal.users_to_notify.each do |user|
        proposal_notification.add(user, @proposal_notification)
      end
      redirect_to messages_proposal_dashboard_path(@proposal_notification.proposal), notice: I18n.t("flash.actions.create.proposal_notification")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @proposal_notification.update(proposal_notification_params)
      redirect_to messages_proposal_dashboard_path(@proposal_notification.proposal), notice: "Benachrichtigung aktualisiert"
    else
      render :new
    end
  end

  def destroy
    fallback_path = messages_proposal_dashboard_path(@proposal_notification.proposal)

    if @proposal_notification.destroy
      redirect_back fallback_location: fallback_path, notice: "Benachrichtigung gelöscht"
    else
      redirect_back fallback_location: fallback_path, alert: "Benachrichtigung nicht gelöscht"
    end
  end

  def show
    @notification = ProposalNotification.find(params[:id])
  end

  private

    def proposal_notification_params
      params.require(:proposal_notification).permit(allowed_params)
    end

    def allowed_params
      [:title, :body, :proposal_id]
    end
end
