module SharedActions
  def setup_projekt(labels: false)
    projekt = create(:projekt)
    projekt.projekt_settings.find_by(key: "projekt_feature.main.activate").update!(value: true)
    projekt.debate_phase.update!(active: true, start_date: 1.month.ago, end_date: 1.month.from_now)
    projekt.proposal_phase.update!(active: true, start_date: 1.month.ago, end_date: 1.month.from_now)
  end

  def select_projekt_in_selector(labels: false)
  end
end
