class ProjektPhase::CommentPhase < ProjektPhase
  def phase_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.comment").value.present?
  end

  def phase_info_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.comment_info").value.present?
  end

  def name
    'comment_phase'
  end

  def resources_name
    'comments'
  end
end
