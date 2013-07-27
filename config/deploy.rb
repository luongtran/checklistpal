set :application, "Checklist Pal"
set :scm, :git
set :repository,  "C://Sites//checklistpal"
set :scm_passphrase, ""
set :user, "ubuntu"
set :password, ""
server "50.112.165.229", :app, :primary => true
set :deploy_to, "/var/www/checklistpal"
set :use_sudo, false
ssh_options[:keys] = ["D://tudli.pem"]
# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "50.112.165.229"                          # Your HTTP server, Apache/etc
role :app, "50.112.165.229"                          # This may be the same as your `Web` server
role :db,  "50.112.165.229", :primary => true # This is where Rails migrations will run