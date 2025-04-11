# Changelog
## Unreleased (2025-04-09)
- Significant rework of the harvester.
- Bump virtuoso
- Re-wire authorization config
### deploy instructions
Since significant changes, we'll go for a full wipe.
###3 For dev/qa/production

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
