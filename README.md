# Otwarte Zabytki

### License

The project is licensed under a 3-clause BSD license. You can find the whole text of the license [here](https://github.com/otwartezabytki/otwartezabytki/blob/master/LICENSE).

### Requirements (for OS X)
Your machine should be equipped with:
  - homebrew
  - ruby 1.9.2 or 1.9.3, below than 2.0.0 (we recommend using rbenv)
  - git
  - bundle
  - web browser e.g. chrome or safari

### Application setup (for OS X)

```
brew update
brew install elasticsearch memcached postgresql imagemagick aspell --lang=pl
brew pin elasticsearch postgresql
cp config/database.yml.example config/database.yml
# create database and database users for dev and testing
bundle install
# load database dump if you have
gunzip -c %m_%d_%Y.sql.gz | script/rails db
bundle exec rake db:migrate
bundle exec rake db:seed
```

Setup ElasticSearch (we use 0.20.2)
 - install according to this: https://github.com/karmi/tire#installation
 - install Morfologik (Polish) Analysis for ElasticSearch from: https://github.com/chytreg/elasticsearch-analysis-morfologik
 - index the data:

```
bundle exec rake relic:reindex
```

### [Attention] Updating settings.yml

After editing this file you have to edit also variables.js.etc in assets.
If you don't do that, the settings won't be applied.

### Dumping database

```
pg_dump -h localhost -cxOWU user_name db_name | gzip > (date +"%m_%d_%Y").sql.gz
```

### Redactor.js license

Redactor.js is proprietary software, you can disable it by issuing following commands:

```
rm $(find app -type f -name 'redactor*')
sed -i '.bak' '/redactor/d' $(grep -l -E '/redactor|)\.redactor' -r app)
```

### I18n translations

  - Every new translation key add to pl.yml with default value.
  - On deploy default values are copied to database via `bash rake tolk:sync`.
  - To change already added translation key use tolk or inline interface (you must be an admin).
  - From time to time you want to pull production translations and save in pl.yml `bash script/load_production_translations` command make dump on production load it to local db run sync and dump merged yml file.

### Troubleshooting

Problem:
```
500 : {"error":"SearchPhaseExecutionException[Failed to execute phase [query], total failure; shardFailures {[_na_][development-relics][0]: No active shards}{[_na_][development-relics][1]: No active shards}{[_na_][development-relics][2]: No active shards}{[_na_][development-relics][3]: No active shards}{[_na_][development-relics][4]: No active shards}]","status":500}
```

Solution:

    rm -rf /usr/local/var/elasticsearch/elasticsearch_$(whoami)/*
    elasticsearch restart

### Code documentation

```
  gem install yard redcarpet
```

in application directory run

```ruby
  yard -o public/system/doc
```

current code documentation is available on http://rubydoc.info/github/otwartezabytki/otwartezabytki/master/frames

### API documentation
is available on http://otwartezabytki.pl/apidoc/index.html


