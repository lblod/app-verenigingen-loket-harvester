# Changelog

# Unreleased

- Bump `lblod/harvesting-verenigingen-import-service` use autocommit for graph move
- `job-alert-service` creates mails for any failed job

## Deploy notes

Overwrite this configuration in docker-compose.override.yml

```yaml
  job-alert:
    environment:
      EMAIL_FROM: 'noreply@lblod.info'
      EMAIL_TO: 'noreply@lblod.info'
```

# 1.5.2

- Bump `harvesting-cleanup-previous-jobs-service`

## Deploy notes

For the `harvesting-cleaning` environment variables: overwrite the
`MAX_DAYS_TO_KEEP_SUCCESSFUL_JOBS`, `MAX_DAYS_TO_KEEP_BUSY_JOBS`,
`MAX_DAYS_TO_KEEP_FAILED_JOBS` to your liking and up the service.

```
drc up -d harvesting-cleaning
```

# 1.5.1

- mutatiedienst optimizations
- import service waits for db to be ready during initialization
- [CLBV-1084] Include metrics for long running harvest jobs.

## Deploy notes

You might want to change these settings in docker-compose.override.yml:

```yaml
  harvest_scraper:
    environment:
      PUBLIC_API_BASE_VERENIGINGENREGISTER: 'http://publiek.verenigingen.vlaanderen.be' # if harvesting from production
      FEATURE_SKIP_UNEXPECTED_RESPONSE_FROM_SOURCE: 'true' # change to false to hard fail again on unexpected responses (502s)
```

```
git checkout config/delta-producer/background-job-initiator/config.json
# ensure initial sync runs
sed -i 's/"startInitialSync": false/"startInitialSync": true/' config/delta-producer/background-job-initiator/config.json
drc stop
drc up -d
```

Then, through the frontend, ensure in the scheduled jobs, the harvesjob cron pattern is changed to `30 03 * * *`.

### About the metrics [CLBV-1084]

You'll have to ping Felix or Niels to wire this into the warning system

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
