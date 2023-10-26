class ProjektManagement::SiteCustomization::ContentBlocksController < ProjektManagement::BaseController
  load_and_authorize_resource :content_block, class: "SiteCustomization::ContentBlock",
                               except: [
                                 :delete_heading_content_block,
                                 :edit_heading_content_block,
                                 :update_heading_content_block
                               ]

  def edit
    @selected_content_block = @content_block.name
    render "custom/admin/site_customization/content_blocks/edit"
  end

  def update
    if @content_block.update(content_block_params)
      notice = t("admin.site_customization.content_blocks.update.notice")
      return_to = params[:return_to]
      redirect_to (return_to.presence || admin_site_customization_content_blocks_path), notice: notice
    else
      flash.now[:error] = t("admin.site_customization.content_blocks.update.error")
      render :edit
    end
  end

  private

    def content_block_params
      params.require(:site_customization_content_block).permit(allowed_params)
    end

    def allowed_params
      [:name, :locale, :body]
    end
end
