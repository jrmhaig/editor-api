web: bundle exec puma -C config/puma.rb
release: bundle exec rails db:migrate && bundle exec rake projects:create_starter
worker: bundle exec good_job start --max-threads=8
