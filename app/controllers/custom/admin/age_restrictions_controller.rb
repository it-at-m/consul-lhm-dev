class Admin::AgeRestrictionsController < Admin::BaseController
  include Translatable
  before_action :set_age_restriction, only: %i[edit update destroy]

  def index
    @age_restrictions = AgeRestriction.all.order(order: :asc)
  end

  def new
    @age_restriction = AgeRestriction.new
  end

  def create
    @age_restriction = AgeRestriction.new(age_restriction_params)

    if @age_restriction.save
      redirect_to admin_age_restrictions_path
    end
  end

  def edit
  end

  def update
    if @age_restriction.update(age_restriction_params)
      redirect_to admin_age_restrictions_path
    end
  end

  def destroy
    @age_restriction.destroy!

    redirect_to admin_age_restrictions_path
  end

  private

    def set_age_restriction
      @age_restriction = AgeRestriction.find(params[:id])
    end

    def age_restriction_params
      params.require(:age_restriction).permit(:order, :min_age, :max_age, translation_params(AgeRestriction))
    end
end
