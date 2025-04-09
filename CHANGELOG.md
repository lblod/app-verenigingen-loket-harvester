# Changelog
## Unreleased (2025-04-09)
- Significant rework of the harvester.
- Bump virtuoso 
### deploy instructions
Since significant changes, we'll go for a full wipe.
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
# make a backup
rm -rf data
drc up -d migrations
```
Then follow the steps in the `README.md`
