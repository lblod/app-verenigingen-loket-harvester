import promClient from 'prom-client';
import { querySudo } from '@lblod/mu-auth-sudo';

const longRunningFullHarvestJobsGauge = new promClient.Gauge({
  name: 'full_harvest_jobs_running_longer_than_1h',
  help: 'Count of full harvest jobs that are running longer than 1 hour.'
});

const longRunningIncrementalHarvestJobsGauge = new promClient.Gauge({
  name: 'incremental_harvest_jobs_running_longer_than_10m',
  help: 'Count of incremental harvest jobs that are running longer than 10 minutes.'
});

const register = promClient.register;

const longRunningFullHarvestJobsQuery = `
PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>
PREFIX dct:  <http://purl.org/dc/terms/>
PREFIX cogs: <http://vocab.deri.ie/cogs#>
PREFIX adms: <http://www.w3.org/ns/adms#>
PREFIX task: <http://redpencil.data.gift/vocabularies/tasks/>

SELECT (COUNT(?job) as ?jobs)
WHERE {
  ?job
    a cogs:Job ;
    adms:status <http://redpencil.data.gift/id/concept/JobStatus/busy> ;
    task:operation <http://lblod.data.gift/id/jobs/concept/JobOperation/lblodHarvesting> ;
    dct:created ?created .
  BIND((NOW() - "PT1H"^^xsd:duration) AS ?yestertime)
  FILTER(?created < ?yestertime)
}
`;

const longRunningIncrementalHarvestJobsQuery = `
PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>
PREFIX dct:  <http://purl.org/dc/terms/>
PREFIX cogs: <http://vocab.deri.ie/cogs#>
PREFIX adms: <http://www.w3.org/ns/adms#>
PREFIX task: <http://redpencil.data.gift/vocabularies/tasks/>

SELECT (COUNT(?job) as ?jobs)
WHERE {
  ?job
    a cogs:Job ;
    adms:status <http://redpencil.data.gift/id/concept/JobStatus/busy> ;
    task:operation <http://lblod.data.gift/id/jobs/concept/JobOperation/incrementalCollecting> ;
    dct:created ?created .
  BIND((NOW() - "PT10M"^^xsd:duration) AS ?yestertime)
  FILTER(?created < ?yestertime)
}
`;

async function updateLongRunningFullHarvestJobs() {
  const response = await querySudo(longRunningFullHarvestJobsQuery);
  if (response.results.bindings) {
    const binding = response.results.bindings[0];
    const count = parseInt(binding.jobs.value);
    longRunningFullHarvestJobsGauge.set(count);
  }
}

async function updateLongRunningIncrementalHarvestJobs() {
  const response = await querySudo(longRunningIncrementalHarvestJobsQuery);
  if (response.results.bindings) {
    const binding = response.results.bindings[0];
    const count = parseInt(binding.jobs.value);
    longRunningIncrementalHarvestJobsGauge.set(count);
  }
}

export default {
  name: 'Long running jobs',
  cronPattern: '* * * * *',
  async cronExecute() {
    await updateLongRunningFullHarvestJobs();
    await updateLongRunningIncrementalHarvestJobs();
  },
  async metrics() {
    // not returning anything
  }
}
