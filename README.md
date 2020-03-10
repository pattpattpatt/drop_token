# README

### System dependencies
This was tested on ruby 2.6.2
This was built with Rails 6.0.2

### Configuration
- Install (rbenv)[https://github.com/rbenv/rbenv#installation]
- Install Ruby 2.6.2 via `rbenv install 2.6.2`
- (Install postgres)[https://www.postgresql.org/download/macosx/] and start the server
- Install bundler, the ruby package manager: (instructions)[https://bundler.io/]

### Database Initialization
Run the following commands to set up the database

  bundle install
  bundle exec rails db:setup
  bundle exec rails db:migrate

### Run the server locally

  bundle exec rails s
