# Changelog
## Unreleased (2025-04-09)
- Significant rework of the harvester.
- Bump virtuoso 
### deploy instructions
Since significant changes, we'll go for a full wipe.
```
drc down
# make a backup
rm -rf data
drc up -d migrations
```
Then follow the steps in the `README.md`
