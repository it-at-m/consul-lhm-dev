namespace :one_time_tasks do
  desc "Migrate projekt resources to projekt phases"
  task migrate_projekt_resources_to_projekt_phases: :environment do
    # Migrate budgets
    Budget.all.each { |b| b.update(projekt_phase: b.old_projekt.budget_phases.first) if b.old_projekt.present? }

    # Migrate projekt arguments
    ProjektArgument.all.each { |pa| pa.update(projekt_phase: pa.old_projekt.argument_phases.first) }

    # Migrate projekt questions
    ProjektQuestion.all.each { |pq| pq.update(projekt_phase: pq.old_projekt.question_phases.first) }

    # Migrate Livestreams
    ProjektLivestream.all.each { |pl| pl.update(projekt_phase: pl.old_projekt.livestream_phases.first) }

    # Migrate ProjektNotifications
    ProjektNotification.all.each { |pn| pn.update(projekt_phase: pn.old_projekt.projekt_notification_phases.first) }

    # Migrate ProjektEvents
    ProjektEvent.all.each { |pe| pe.update(projekt_phase: pe.old_projekt.event_phases.first) }

    # Migrate Debates
    Debate.all.each { |de| de.update(projekt_phase: de.old_projekt.debate_phases.first) if de.old_projekt.present?}

    # Migrate Proposals
    Proposal.all.each { |pr| pr.update(projekt_phase: pr.old_projekt.proposal_phases.first) if pr.old_projekt.present?}

    # Migrate Polls
    Poll.all.each { |poll| poll.update(projekt_phase: poll.old_projekt.voting_phases.first )}

    # Migrate map layers from projekt to mappable
    MapLayer.where.not(projekt_id: nil).map{ |ml| ml.update(mappable_type: "Projekt", mappable_id: ml.projekt_id, projekt_id: nil) }
    ProjektPhase::ProposalPhase.all.map(&:create_map_location)


    # Migrate projekt labels for debates and proposals, then delete
    Debate.all.each { |debate| debate.projekt_labels.where.not(projekt_id: nil).each { |pl| new_label = debate.projekt_phase.projekt_labels.find_or_create_by!(color: pl.color, icon: pl.icon, name: pl.name, projekt_phase_id: debate.projekt_phase.id);  debate.projekt_labels << new_label unless debate.projekt_labels.exists?(id: new_label.id) }}
    Proposal.all.each { |proposal| proposal.projekt_labels.where.not(projekt_id: nil).each { |pl| new_label = proposal.projekt_phase.projekt_labels.find_or_create_by!(color: pl.color, icon: pl.icon, name: pl.name, projekt_phase_id: proposal.projekt_phase.id); proposal.projekt_labels << new_label unless proposal.projekt_labels.exists?(id: new_label.id) }}
    ProjektLabel.where.not(projekt_id: nil).destroy_all

    # Migrate milestones
    Projekt.all.each { |projekt| projekt.milestones.update_all(milestoneable_id: projekt.milestone_phases.first.id, milestoneable_type: ProjektPhase) }

    # Migrate comments
    Projekt.where.not(special: true).each { |projekt| projekt.comments.each { |comment| comment.update(commentable_type: "ProjektPhase", commentable_id: projekt.comment_phases.first.id ) } }

    # Migrate legislation processes
    Legislation::Process.all.each { |lp| lp.update(projekt_phase: lp.old_projekt.legislation_phases.first) if lp.old_projekt.present? }
  end

  desc "Update data for new desgin"
  task new_design_data_update: :environment do
    Projekt.find_each do |projekt|
      if projekt.parent&.parent_id.present?
        projekt.top_level_projekt_id = projekt.parent.parent_id
      end

      projekt.save!
    end
  end
end
