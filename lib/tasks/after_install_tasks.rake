namespace :after_install_tasks do
  desc "Running after install tasks"

  task run_all: :environment do
    ApplicationLogger.new.info "Running all after install tasks"
    Rake::Task["after_install_tasks:create_special_projekt"].execute
  end

  task create_special_projekt: :environment do
    ApplicationLogger.new.info "Creating projekt for Projekt overview page"
    Projekt.find_or_create_by!(
      name: "Overview page",
      special_name: "projekt_overview_page",
      special: true
    )
  end
end
