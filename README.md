# Otwarte Zabytki

### Application setup

```bash
brew update
brew install elasticsearch postgresql graphicsmagick aspell --lang=pl
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

#### Production only:

To enable periodical dump of `relics.csv` ou need to create initial dump of relics:

```bash
bundle exec rake relic:export_init[public/system/relics_history.csv]
```

Then, you can incrementially export users' suggestions by executing following command periodically:

```bash
bundle exec rake relic:export[public/system/relics_history.csv]
```

Cron jobs auto-setup is also available, just run ```bundle exec whenever --update-crontab```

# Updating settings.yml

After editing this file you have to edit also variables.js.etc in assets.
If you don't do that, the settings won't be applied.

### Dumping database

```bash:
  pg_dump -h localhost -cxOWU user_name db_name | gzip > db/dump/$(date +"%m_%d_%Y").sql.gz
```

