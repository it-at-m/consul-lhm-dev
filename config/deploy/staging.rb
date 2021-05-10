set :branch, ENV["branch"] || :cli_bam

server deploysecret(:server), user: deploysecret(:user), roles: %w[web app db importer cron background]
