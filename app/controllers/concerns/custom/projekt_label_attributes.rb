module ProjektLabelAttributes
  extend ActiveSupport::Concern

  included do
    before_action :filter_projekt_labels, only: [:create, :update]
  end

  private

    def filter_projekt_labels
      case controller_name
      when "debates"
        return if params[:debate][:projekt_id].blank?

        projekt = Projekt.find(params[:debate][:projekt_id])
        aceptable_label_ids = projekt.all_projekt_labels.ids.map(&:to_s)
        params[:debate][:projekt_label_ids] = params[:debate][:projekt_label_ids] & aceptable_label_ids
      when "proposals"
        return if params[:proposal][:projekt_id].blank?

        projekt = Projekt.find(params[:proposal][:projekt_id])
        aceptable_label_ids = projekt.all_projekt_labels.ids.map(&:to_s)
        params[:proposal][:projekt_label_ids] = params[:proposal][:projekt_label_ids] & aceptable_label_ids
      end
    end
end
