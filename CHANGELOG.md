# Changelog

# Unreleased

- mutatiedienst optimizations
- import service waits for db to be ready during initialization
- [CLBV-1069] bump virtuoso to 1.3.0 and bump the job controllers to 1.2.x. Make sure to follow the deploy notes below.

## Deploy notes

### Updgrade virtuoso db

see also the [virtuoso docker image readme](https://github.com/redpencilio/docker-virtuoso/).

NOTE: Upgrading virtuoso is a procedure to be done with great care, make sure to have backups before starting.

#### 1. dump nquads

When upgrading it's recommended (and sometimes required!) to first dump to quads using the `dump_nquads` procedure:

```sh
docker compose exec virtuoso isql-v
SQL> dump_nquads ('dumps', 1, 1000000000, 1);
```

#### 2. stop the db

```sh
docker compose stop virtuoso
```

#### 3. remove old db and related files

When this has completed move the dumps folder to the toLoad folder. Make sure to remove the following files:

- `.data_loaded`
- `.dba_pwd_set`
- `virtuoso.db`
- `virtuoso.trx`
- `virtuoso.pxa`
- `virtuoso-temp.db`

```sh
mv data/db/dumps/* data/db/toLoad
rm data/db/virtuoso.{db,trx,pxa} data/db/virtuoso-temp.db data/db/.data_loaded data/db/.dba_pwd_set
```

Consider truncating or removing the virtuoso.log file as well.

### 4. update virtuoso version

Check out this branch/release verify to be on expected branch and version.

docker-compose.yml should contain:

```yaml
virtuoso:
  image: redpencil/virtuoso:1.3.0
```

### 5. start the db

Start the DB and monitor the logs, importing the nquads might take a long time .

```sh
docker compose up -d virtuoso
docker compose logs -f virtuoso
```

After that your application can be started again and you should be good to go.

```
git checkout config/delta-producer/background-job-initiator/config.json
# ensure initial sync runs
sed -i 's/"startInitialSync": false/"startInitialSync": true/' config/delta-producer/background-job-initiator/config.json
drc stop
drc up -d
```

Then, through the frontend, ensure in the scheduled jobs, the harvesjob cron pattern is changed to `30 03 * * *`.

# 1.4.0

- Ensure missing restart directive are set [DL-6508]
- Extract internal ID [CLBV-1054]
- Include export of ETag as `pav:version` on associations [CLBV-1046]
- `isPrimary` contact point [CLBV-1058]
- Harvest address register uri [CLBV-1065]
- Add status mapping for 'gestopt' [CLBV-1059]

# 1.3.1

- fix and improved verenigingregister api response handling [#15](https://github.com/lblod/harvesting-verenigingen-scraper-service/pull/15)

# 1.3.0

- Update type vereniging [#13](https://github.com/lblod/app-verenigingen-loket-harvester/pull/13)
  - [CLBV-891]
- Further cleanup

# 1.2.1

- fix docker-image-name
- fix missing properties in `mu-resource`-config

## Deploy instructions

```
drc restart resource
drc up -d
```

# 1.2.0

- Clean-up old files and jobs [CLBV-946]
- Map status to status URI [CLBV-987]

## Deploy instructions

**Restarts for clean-up jobs**

```
docker compose restart job-controller scheduled-job-controller migrations;
drc up -d
```

## 1.1.0

- Bump `migrations` to `v0.9.0`.
- Add missing `logging` key to `migrations`. [DL-6490]
- Significant rework of the harvester.
- Bump virtuoso
- Re-wire authorization config

### Deploy Notes

:warning: If you didn't use `mu-script` to generate an old account, it might not work anymore, because re-write of `mu-auth`.
Ensure there is a similar triple linked to the account `<http://data.lblod.info/foaf/group/id/25e40ddc-0532-435d-a13f-7a2877cde5a7> foaf:member accounts:123.`.
Or you can generate a new account, check instructions `README.md`

Since significant changes, we'll go for a full wipe.

### For dev/qa/production

If deploy on dev/qa/production, you will first have to make sure the `config.override.json` is updated.

```
cd ./config/delta-producer/publication-graph-maintainer
cat config.override.json
// Should contain field: "key": "random key"
// Keep that key somewhere...!!!
cp config.json config.override.json
// Insert the "key": "random key" again
```

Then the effective deploy:

```
drc down
// Make a backup!!
rm -rf data
drc up -d migrations
```

When done, first make sure that the initial sync will not start when starting the application.
Ensure that

```
// cat config/delta-producer/background-job-initiator/config.json
[
  {
    (...)
    "startInitialSync": false, ----> FALSE!!
    (...)
  }
]

```

```
drc up -d
```

Then follow the steps in the `README.md` to schedule or start a new job.
Once that job is ready (+/- 20 min), you still need to publish the data.
Again, follow the steps in the `README.md`, section "Setting up the Delta-Producers"
