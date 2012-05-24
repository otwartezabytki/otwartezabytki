# otwarte zabytki

### application init
 - db setup, cp config/database.yml.example config/database.yml
 - bundle install
 - bundle exec rake db:migrate
 - gunzip -c db/dump/%m_%d_%Y.sql.gz | script/rails db
 - script/rails s

### db dump command
```bash:
  pg_dump -c db_name | gzip > db/dump/$(date +"%m_%d_%Y").sql.gz
```