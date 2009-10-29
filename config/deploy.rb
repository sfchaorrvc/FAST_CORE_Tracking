set(:customer_name) do
  Capistrano::CLI.ui.ask "Enter Customer name: "
end

set :keep_releases, 5
set :application,   'ublip'
set :scm_username,  'deploy'
set :scm_password,  'wucr5ch8v0'
set :user,          'ublip'
#set :password,      ''
set :deploy_to, DeployManagerClient.get_app_directory(customer_name)
set :deploy_via,    :export
set :monit_group,   'mongrel'
set :scm,           :subversion
set :runner, 'ublip'
ssh_options[:paranoid] = false

task :production do
  set :rails_env, 'production'
  set :monited, 'y'
  role :db, DeployManagerClient.get_app_servers(customer_name)[0], :primary => true
  app_servers = DeployManagerClient.get_app_servers(customer_name)
  app_servers.each_index do |index|
    if index=0
      role :app, app_servers[index]
    else
      role :app, app_servers[index], :no_release => true, :no_symlink => true, :no_daemons => true
    end
  end
  set :repository, "#{DeployManagerClient.get_repo(customer_name)}/tags/current_production_build"
end

task :staging do
  set :rails_env, 'staging'
  set :monited, 'n'
  role :db, DeployManagerClient.get_staging_app_server(customer_name), :primary => true
  role :app, DeployManagerClient.get_staging_app_server(customer_name), :mongrel => true
  set :repository, "#{DeployManagerClient.get_repo(customer_name)}/tags/current_staging_build"
end

# Don't change unless you know what you are doing!
after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"
# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"
before "deploy", "daemons:stop"
after "deploy", "daemons:start"
after "deploy", "setup_db_procs"
after "deploy:migrate", "setup_db_procs"
after "deploy:migrations", "setup_db_procs"

namespace :mongrel do
  desc <<-DESC
 Start Mongrel processes on the app server.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is
 set to true.
 DESC
  task :start, :roles => :app do
    if monited.eql?("y")
      sudo "/usr/sbin/monit start all -g #{monit_group}"
    else
      run "cd /opt/ublip/rails/current; mongrel_rails cluster::start;"
    end
  end
  
  desc <<-DESC
 Restart the Mongrel processes on the app server by starting and stopping the cluster. This uses the :use_sudo
 variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
 DESC
  task :restart, :roles => :app do
    if monited.eql?("y")
      sudo "/usr/sbin/monit restart all -g #{monit_group}"
    else
      run "cd /opt/ublip/rails/current; mongrel_rails cluster::restart;"
    end
  end
  
  desc <<-DESC
 Stop the Mongrel processes on the app server.  This uses the :use_sudo
 variable to determine whether to use sudo or not. By default, :use_sudo is
 set to true.
 DESC
  task :stop, :roles => :app do
    if monited.eql("y")
      sudo "/usr/sbin/monit stop all -g #{monit_group}"
    else
      run "cd /opt/ublip/rails/current; mongrel_rails cluster::stop;"
    end
  end
  
  desc "Get the status of your mongrels"
  task :status, :roles => :app do
    @monit_output ||= { }
    sudo "/usr/sbin/monit status" do |channel, stream, data|
      @monit_output[channel[:server].to_s] ||= [ ]
      @monit_output[channel[:server].to_s].push(data.chomp)
    end
    @monit_output.each do |k,v|
      puts "#{k} -> #{'*'*55}"
      puts v.join("\n")
    end
  end
end

namespace :nginx do
  desc "Start Nginx on the app server."
  task :start, :roles => :app do
    sudo "/etc/init.d/nginx start"
  end
  
  desc "Restart the Nginx processes on the app server by starting and stopping the cluster."
  task :restart , :roles => :app do
    sudo "/etc/init.d/nginx restart"
  end
  
  desc "Stop the Nginx processes on the app server."
  task :stop , :roles => :app do
    sudo "/etc/init.d/nginx stop"
  end
  
  desc "Tail the nginx logs for this environment"
  task :tail, :roles => :app do
    run "tail -f /var/log/engineyard/nginx/vhost.access.log" do |channel, stream, data|
      puts "#{channel[:server]}: #{data}" unless data =~ /^10\.[01]\.0/ # skips lb pull pages
      break if stream == :err
    end
  end
end

namespace(:deploy) do
  task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
    run <<-CMD
     cd #{release_path} &&
     ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
     ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml
   CMD
  end
  
  desc "Long deploy will throw up the maintenance.html page and run migrations
       then it restarts and enables the site again."
  task :long do
    transaction do
      update_code
      web.disable
      symlink
      migrate
    end
    
    restart
    web.enable
  end
  
  desc "Restart the Mongrel processes on the app server by calling restart_mongrel_cluster."
  task :restart, :roles => :app do
    mongrel.restart
  end
  
  desc "Start the Mongrel processes on the app server by calling start_mongrel_cluster."
  task :spinner, :roles => :app do
    mongrel.start
  end
  
  desc "Tail the Rails production log for this environment"
  task :tail_production_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:server]} -> #{data}"
      break if stream == :err
    end
  end
end

namespace :db do
  task :backup_name do
    now = Time.now
    run "mkdir -p #{shared_path}/db_backups"
    backup_time = [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
    set :backup_file, "#{shared_path}/db_backups/#{environment_database}-snapshot-#{backup_time}.sql"
  end
  
  desc "Clone Production Database to Staging Database."
  task :clone_prod_to_stage, :roles => :db, :only => { :primary => true } do
    backup_name
    on_rollback { run "rm -f #{backup_file}" }
    run "mysqldump --add-drop-table -u #{sql_user} -h #{sql_host} -p#{sql_pass} #{production_database} > #{backup_file}"
    run "mysql -u #{sql_user} -p#{sql_pass} -h #{sql_host} #{stage_database} < #{backup_file}"
    run "rm -f #{backup_file}"
  end
  
  desc "Backup your Database to #{shared_path}/db_backups"
  task :dump, :roles => :db, :only => {:primary => true} do
    backup_name
    run "mysqldump --add-drop-table -u #{sql_user} -h #{sql_host} -p#{sql_pass} #{environment_database} | bzip2 -c > #{backup_file}.bz2"
  end
end 

namespace :daemons do
  desc "Start all daemons"
  task :start, :roles => :app, :except => {:no_daemons => true} do
    run "#{current_path}/script/daemons start"
  end
  
  desc "Stop all daemons"
  task :stop, :roles => :app, :except => {:no_daemons => true} do
      run "#{current_path}/script/daemons stop"
  end
end