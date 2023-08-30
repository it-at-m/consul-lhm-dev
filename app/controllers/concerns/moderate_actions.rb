module ModerateActions
  extend ActiveSupport::Concern
  include Polymorphic
  PER_PAGE = 50

  def index
    if params[:only_with_flags] == "true" && @resources.column_names.include?("flags_count")
      @resources = @resources.where("flags_count > 0")
    end

    @resources = @resources.send(@current_filter)
                           .send("sort_by_#{@current_order}")
                           .page(params[:page])
                           .per(PER_PAGE)

    set_resources_instance
  end

  def hide
    hide_resource resource
  end

  def moderate
    set_resource_params
    @resources = @resources.where(id: params[:resource_ids])

    if params[:hide_resources].present?
      # @resources.accessible_by(current_ability, :hide).each { |resource| hide_resource resource }
      ## resource_ids = @resources.select{ |r| can?(:hide, r) }.pluck(:id)
      ## @resources.where(id: resource_ids).each { |resource| hide_resource resource }
      @resources.select { |r| can?(:hide, r) }.each { |resource| hide_resource resource }
    elsif params[:ignore_flags].present?
      # @resources.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)
      ## resource_ids = @resources.select{ |r| can?(:ignore_flag, r) }.pluck(:id)
      ## @resources.where(id: resource_ids).each(&:ignore_flag)
      @resources.select { |r| can?(:ignore_flag, r) }.each(&:ignore_flag)
    elsif params[:block_authors].present?
      author_ids = @resources.pluck(author_id)
      User.where(id: author_ids).each { |user| block_user user }
    end

    redirect_with_query_params_to(action: :index)
  end

  private

    def load_resources
      # @resources = resource_model.accessible_by(current_ability, :moderate)
      resource_ids = resource_model.select{ |r| can?(:moderate, r) }.pluck(:id)
      @resources = resource_model.where(id: resource_ids)
    end

    def hide_resource(resource)
      resource.hide
      Activity.log(current_user, :hide, resource)
    end

    def block_user(user)
      user.block
      Activity.log(current_user, :block, user)
    end

    def set_resource_params
      params[:resource_ids] = params["#{resource_name}_ids"]
      params[:hide_resources] = params["hide_#{resource_name.pluralize}"]
    end

    def author_id
      :author_id
    end
end
