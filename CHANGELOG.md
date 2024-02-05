# Changelog
## 0.14.4 (2023-10-26)
- bump dump file publisher
## 0.11.0 (2023-03-10)
- bump frontend with new features
  - add login feature flag (turn login on/off)
  - model change, store job auth info in harvest-collection instead of remote data object
- add authentication configuration to harvest-collection model (resources)
- bump harvest collector to support authentication configuration model change
## 0.10.0 (2023-02-23)
### :rocket: Enhancement
 - added support for authentication in normal jobs (scheduled jobs is still WIP)
## 0.9.0 (2022-12-02)
### :rocket: Enhancement
- improve performance by using a diff step by @nbittich in https://github.com/lblod/app-lblod-harvester/pull/19
- Upgrade virtuoso's config to offset to more than 1 million by @claire-lovisa in https://github.com/lblod/app-lblod-harvester/pull/17
- Add agendas and decision lists to the export by @claire-lovisa in https://github.com/lblod/app-lblod-harvester/pull/14
- Add error-alert service to receive emails when things go wrong by @claire-lovisa in https://github.com/lblod/app-lblod-harvester/pull/15
- Skip mu-auth for dump and initial sync jobs by @claire-lovisa in https://github.com/lblod/app-lblod-harvester/pull/16
- Add jobs to harvest Cevi and Remmicom by @claire-lovisa in https://github.com/lblod/app-lblod-harvester/pull/18
## 0.8.0 (2022-10-06)
### :rocket: Enhancement
- Bump frontend which includes some new features:
  - Allow users to filter the results by status
  - Show the target URI in the overview table
## 0.7.1 (2022-06-28)
### :bug: Fixes
- Revert frontend bump - causes issues with previous data
## 0.7.0 (2022-06-28)
### :bug: Fixes
- Sprintf worarounds
- Graph updates
- URI updates
### :rocket: Enhancement
- Bump multiple dependencies to use latest version of mu-auth-sudo (retry mechanism on queries)
- Bump frontend
## 0.6.0 (2022-03-11)
- Added the possibility to partially update scheduled jobs
## 0.5.1 (2021-12-17)
#### :bug: Bug Fix
- CVE-2021-45046: see https://spring.io/blog/2021/12/10/log4j2-vulnerability-and-spring-boot

## 0.5.0 (2021-11-04)
### :rocket: Enhancement
- bump of various services related to deltas (fixing bugs mainly)
- Important changes related to performance
  - harvest-collector: added queue processing and use parts of comunica instead of marawa to speed up parsing.
  - harvesting-import: use parts of comunica instead of marawa to speed up parsing.

## 0.4.1 (2021-10-07)
### :rocket: Enhancement
 - Bump new version of import-sameas, which might tackle some hanging jobs if no triples were found.
## 0.4.0 (2021-09-29)
### :rocket: Enhancement
 - Scheduled jobs
 - Less strict validation for motivation
## 0.3.0 (2021-09-09)
### :bug: Fixes
 - Update producer for missing properties on besluit and artikel
### :rocket: Enhancement
 - Report on broken URl's after publishing
