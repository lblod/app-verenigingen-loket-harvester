import promClient from 'prom-client';
import { querySudo } from '@lblod/mu-auth-sudo';

const STATUS_BUSY = 'http://redpencil.data.gift/id/concept/JobStatus/busy';
const STATUS_SCHEDULED = 'http://redpencil.data.gift/id/concept/JobStatus/scheduled';
const FULL_HARVEST = 'http://lblod.data.gift/id/jobs/concept/JobOperation/lblodHarvesting';
const INCREMENTAL_HARVEST = 'http://lblod.data.gift/id/jobs/concept/JobOperation/incrementalCollecting';

const longRunningFullHarvestJobsGauge = new promClient.Gauge({
  name: 'full_harvest_jobs_running_longer_than_1h',
  help: 'Count of full harvest jobs that are running longer than 1 hour.'
});

const longRunningIncrementalHarvestJobsGauge = new promClient.Gauge({
  name: 'incremental_harvest_jobs_running_longer_than_10m',
  help: 'Count of incremental harvest jobs that are running longer than 10 minutes.'
});

const oldestUnfinishedJobAgeGauge = new promClient.Gauge({
  name: 'job_oldest_unfinished_age_seconds',
  help: 'Age in seconds of the oldest busy or scheduled job per operation, 0 when there is none.',
  labelNames: ['operation']
});

const lastRefreshGauge = new promClient.Gauge({
  name: 'job_metrics_last_refresh_timestamp_seconds',
  help: 'Unix time of the last successful refresh of the job metrics.'
});

// The query does no date arithmetic on purpose. Virtuoso compares stored
// dateTimes against NOW()-derived values at day precision, which made
// "created more than 1 hour ago" match every busy job. Ages are computed here.
const unfinishedJobsQuery = `
PREFIX dct:  <http://purl.org/dc/terms/>
PREFIX cogs: <http://vocab.deri.ie/cogs#>
PREFIX adms: <http://www.w3.org/ns/adms#>
PREFIX task: <http://redpencil.data.gift/vocabularies/tasks/>

SELECT DISTINCT ?job ?operation ?status ?created
WHERE {
  VALUES ?status {
    <${STATUS_BUSY}>
    <${STATUS_SCHEDULED}>
  }
  ?job
    a cogs:Job ;
    adms:status ?status ;
    task:operation ?operation ;
    dct:created ?created .
}
`;

function operationLabel(operation) {
  return operation.split('/JobOperation/').pop();
}

async function refreshJobMetrics() {
  const response = await querySudo(unfinishedJobsQuery);
  const now = Date.now();

  const jobs = response.results.bindings.map((binding) => {
    const created = Date.parse(binding.created.value);
    return {
      operation: binding.operation.value,
      status: binding.status.value,
      // a job without a readable creation time counts as hanging rather than as invisible
      ageSeconds: Number.isNaN(created) ? Infinity : Math.max(0, (now - created) / 1000)
    };
  });

  // the harvest operations are always reported, so their series exist when nothing is running
  const oldestAge = {
    [operationLabel(FULL_HARVEST)]: 0,
    [operationLabel(INCREMENTAL_HARVEST)]: 0
  };
  for (const job of jobs) {
    const operation = operationLabel(job.operation);
    oldestAge[operation] = Math.max(oldestAge[operation] || 0, job.ageSeconds);
  }

  const countBusyLongerThan = (operation, seconds) =>
    jobs.filter((job) => job.operation === operation && job.status === STATUS_BUSY && job.ageSeconds > seconds).length;

  oldestUnfinishedJobAgeGauge.reset();
  for (const [operation, age] of Object.entries(oldestAge)) {
    oldestUnfinishedJobAgeGauge.set({ operation }, Math.round(age));
  }
  longRunningFullHarvestJobsGauge.set(countBusyLongerThan(FULL_HARVEST, 60 * 60));
  longRunningIncrementalHarvestJobsGauge.set(countBusyLongerThan(INCREMENTAL_HARVEST, 10 * 60));
  lastRefreshGauge.set(Math.floor(now / 1000));
}

export default {
  name: 'Long running jobs',
  cronPattern: '* * * * *',
  async cronExecute() {
    await refreshJobMetrics();
  },
  async metrics() {
    // not returning anything
  }
}
