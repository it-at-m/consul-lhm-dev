set :branch, ENV["branch"]

server deploysecret(:server), user: deploysecret(:user), roles: %w[web app db importer cron background]
