# config valid only for Capistrano 3.1
lock '3.4.0'
 
set :application, 'trile'
set :scm, :git
set :repo_url, 'git@bitbucket.org:sbstn/trile.git'
set :branch, "master"
set :deploy_via, :copy
set :user, 'deploy'
set :migration_role, 'migrator'            # Defaults to 'db'
set :conditionally_migrate, true
 
# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deploy/trile'
set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
 
namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
   after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end
 
 
namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end
 
  after :publishing, :restart
 
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

# Add this in config/deploy.rb
# and run 'cap production deploy:seed' to seed your database
  desc 'Runs rake db:seed'
  task :seed => [:set_rails_env] do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:seed"
        end
      end
    end
  end
end
