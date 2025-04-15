# Changelog
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
