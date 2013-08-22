# Otwarte Zabytki

### Requirements (for OS X)
Your machine should be equipped with:
  - homebrew
  - ruby 1.9.2 or higher (we recommend using rbenv)
  - git
  - bundle
  - web browser e.g. chrome or safari

### Application setup (for OS X)

```bash
  brew update
  brew install elasticsearch memcached postgresql imagemagick aspell --lang=pl
  brew pin elasticsearch postgresql
  cp config/database.yml.example config/database.yml
  # create database and database users for dev and testing
  bundle install
  gunzip -c db/dump/%m_%d_%Y.sql.gz | script/rails db
  bundle exec rake db:migrate
  bundle exec rake db:seed
```

Set up elastic search:

 - install according to this: https://github.com/karmi/tire#installation
 - install Morfologik (Polish) Analysis for ElasticSearch from: https://github.com/chytreg/elasticsearch-analysis-morfologik
 - index the data:

```bash:
  bundle exec rake relic:reindex
```

### [Attention] Updating settings.yml

After editing this file you have to edit also variables.js.etc in assets.
If you don't do that, the settings won't be applied.

### Dumping database

```bash:
  pg_dump -h localhost -cxOWU user_name db_name | gzip > db/dump/$(date +"%m_%d_%Y").sql.gz
```

### Redactor.js license

Redactor.js is proprietary software, you can disable it by issuing following commands:

```bash
  rm $(find app -type f -name 'redactor*')
  sed -i '.bak' '/redactor/d' $(grep -l -E '/redactor|)\.redactor' -r app)
```

### I18n translations

  - Every new translation key add to pl.yml with default value.
  - On deploy default values are copied to database via ```bash rake tolk:sync```.
  - To change translation on production use tolk or inline interface (you muse be an admin).
  - To change sync local yaml file with production run:
  ```bash script/load_production_translations ```
  this make dump on production load it to local db run sync and dump merged yml file.

### Troubleshooting

Problem:

    500 : {"error":"SearchPhaseExecutionException[Failed to execute phase [query], total failure; shardFailures {[_na_][development-relics][0]: No active shards}{[_na_][development-relics][1]: No active shards}{[_na_][development-relics][2]: No active shards}{[_na_][development-relics][3]: No active shards}{[_na_][development-relics][4]: No active shards}]","status":500}

Solution:

    rm -rf /usr/local/var/elasticsearch/elasticsearch_$(whoami)/*
    elasticsearch restart

### Code documentation
```bash
  gem install yard redcarpet
```
in application directory run
```ruby
  yard -o public/system/doc
```
current code documentation is available on http://otwartezabytki.pl/system/doc/index.html

### API documentation
is available on http://otwartezabytki.pl/apidoc/index.html


