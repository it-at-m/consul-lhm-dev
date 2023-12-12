require_dependency Rails.root.join("app", "controllers", "admin", "users_controller").to_s

class Admin::UsersController < Admin::BaseController
  include HasRegisteredAddress

  def index
    @users = @users.send(@current_filter).order_filter(params)
    @users = @users.by_username_email_or_document_number(params[:search]) if params[:search]

    unless params[:format] == "csv"
      if @users.is_a?(Array)
        @users = Kaminari.paginate_array(@users).page(params[:page])
      else
        @users = @users.page(params[:page])
      end
    end

    respond_to do |format|
      format.html
      format.js
      format.csv do
        send_data CsvServices::UsersExporter.call(@users), filename: "users-#{Time.zone.today}.csv"
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    @registered_address_city = @user.registered_address_city
    @registered_address_street = @user.registered_address_street
    @registered_address = @user.registered_address
  end

  def update
    @user = User.find_by(id: params[:id])
    process_temp_attributes_for(@user)

    if @user.errors.none? && @user.update(user_params)
      @user.unverify!
      redirect_to admin_users_path, notice: "Benutzer aktualisiert"

    else
      @registered_address_city = RegisteredAddress::City.find_by(id: params[:form_registered_address_city_id]) if params[:form_registered_address_city_id].present?
      @registered_address_street = RegisteredAddress::Street.find_by(id: params[:form_registered_address_street_id]) if params[:form_registered_address_street_id].present?
      @registered_address = RegisteredAddress.find_by(id: params[:form_registered_address_id]) if params[:form_registered_address_id].present?
      render :edit
    end
  end

  def verify
    @user = User.find(params[:id])
    if @user.verify!
      @verification_result_notice = "Benutzer verifiziert"
      Mailer.manual_verification_confirmation(@user).deliver_later
    else
      @verification_result_notice = "Benutzer konnte nicht verifiziert werden"
    end
  end

  def unverify
    @user = User.find(params[:id])
    @user.update!(verified_at: nil, geozone: nil, unique_stamp: nil)
  end

  private

    def user_params
      set_address_attributes

      params.require(:user).permit(:email,
                                   :first_name, :last_name,
                                   :city_name, :plz, :street_name, :street_number, :street_number_extension,
                                   :registered_address_id)
                                   # :gender, :date_of_birth,
                                   # :document_type, :document_last_digits,
                                   # :password, :password_confirmation)
    end

    def set_address_attributes
      if params[:form_registered_address_id].present? && params[:form_registered_address_id] != "0"
        registered_address = RegisteredAddress.find(params[:form_registered_address_id])
        params[:user][:registered_address_id] = registered_address.id

        params[:user][:city_name] = registered_address.registered_address_city.name
        params[:user][:plz] = registered_address.registered_address_street.plz
        params[:user][:street_name] = registered_address.registered_address_street.name
        params[:user][:street_number] = registered_address.street_number
        params[:user][:street_number_extension] = registered_address.street_number_extension
      end
    end
end
