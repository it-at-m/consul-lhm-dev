class GenerateNewProjektSettings < ActiveRecord::Migration[5.2]
  def up
    ProjektSetting.ensure_existence
  end
end
