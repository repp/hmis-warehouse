# config valid only for current version of Capistrano
lock '3.10.2'

set :application, 'slc_hmis'
set :repo_url, 'git@github.com:repp/hmis-warehouse.git'
set :client, ENV.fetch('CLIENT')

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :cron_user, ENV.fetch('CRON_USER') { 'ubuntu'}
set :whenever_roles, [:cron, :production_cron, :staging_cron]
set :whenever_command, -> { "bash -l -c 'cd #{fetch(:release_path)} && /usr/local/rvm/bin/rvmsudo ./bin/bundle exec whenever -u #{fetch(:cron_user)} --update-crontab #{fetch(:whenever_identifier)} --set \"environment=#{fetch(:rails_env)}\" '" }

if !ENV['FORCE_SSH_KEY'].nil?
  set :ssh_options, {
    keys: [ENV['FORCE_SSH_KEY']],
    port: ENV.fetch('SSH_PORT') { '22' },
    user: ENV.fetch('DEPLOY_USER'),
    forward_agent: true
  }
else
  set :ssh_options, {
    port: ENV.fetch('SSH_PORT') { '22' },
    user: ENV.fetch('DEPLOY_USER'),
    forward_agent: true
  }
end

set :nginx_ssl_certificate, "/var/www/slc-hmis-staging/current/certificates/saltlakecounty-warehouse.brighthive.io-cert.pem"
set :nginx_ssl_certificate_key, "/var/www/slc-hmis-staging/current/certificates/saltlakecounty-warehouse.brighthive.io-key.pem"
set :nginx_use_ssl, true

unless ENV['SKIP_JOBS']=='true'
  set :delayed_job_workers, 2
  set :delayed_job_prefix, "#{ENV['CLIENT']}-hmis-warehouse"
  set :delayed_job_roles, [:job]
  after 'puma:restart', 'delayed_job:restart'
end

set :ssh_port, ENV.fetch('SSH_PORT') { '22' }
set :deploy_user , ENV.fetch('DEPLOY_USER')

if ENV['RVM_CUSTOM_PATH']
  set :rvm_custom_path, ENV['RVM_CUSTOM_PATH']
end

task :group_writable do
  on roles(:web) do
    execute "chmod --quiet g+w -R  #{fetch(:deploy_to)} || echo ok"
    execute "chgrp --quiet ubuntu -R #{fetch(:deploy_to)} || echo ok"
  end
end
after 'puma:restart', :group_writable
after 'deploy:log_revision', :group_writable


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push(
  'config/secrets.yml',
  '.env',
  'app/views/root/_homepage_content.haml'
)

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp',
  'public/system',
  'var',
  'app/assets/stylesheets/theme/styles',
  'app/assets/images/theme/logo',
  'app/assets/images/theme/icons',
)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  before 'assets:precompile', :touch_theme_variables do
    on roles(:app)  do
      within shared_path do
        # must exist for asset-precompile to succeed.
        execute :touch, 'app/assets/stylesheets/theme/styles/_variables.scss'
      end
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

task :echo_options do
  puts "\nDid you run ssh-add before running?\n\n"
  puts "Deploying as: #{fetch(:deploy_user)} on port: #{fetch(:ssh_port)} to location: #{deploy_to}\n\n"
end
after 'git:wrapper', :echo_options
