local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
  // Grafana object reference
  grafana:: g,

  // Common datasources
  datasources:: {
    prometheus:: {
      type: 'prometheus',
      uid: 'prometheus',
    },
    loki:: {
      type: 'loki',
      uid: 'loki',
    },
  },

  // Common threshold configurations
  thresholds:: {
    cpu:: {
      mode: 'absolute',
      steps: [
        { value: null, color: 'green' },
        { value: 70, color: 'yellow' },
        { value: 90, color: 'red' },
      ],
    },
    memory:: {
      mode: 'absolute',
      steps: [
        { value: null, color: 'green' },
        { value: 75, color: 'yellow' },
        { value: 90, color: 'red' },
      ],
    },
    disk:: {
      mode: 'absolute',
      steps: [
        { value: null, color: 'green' },
        { value: 80, color: 'yellow' },
        { value: 95, color: 'red' },
      ],
    },
    latency:: {
      mode: 'absolute',
      steps: [
        { value: null, color: 'green' },
        { value: 500, color: 'yellow' },
        { value: 1000, color: 'red' },
      ],
    },
    errorRate:: {
      mode: 'absolute',
      steps: [
        { value: null, color: 'green' },
        { value: 1, color: 'yellow' },
        { value: 5, color: 'red' },
      ],
    },
  },

  // Common time ranges
  timeRanges:: {
    last1h: { from: 'now-1h', to: 'now' },
    last3h: { from: 'now-3h', to: 'now' },
    last6h: { from: 'now-6h', to: 'now' },
    last12h: { from: 'now-12h', to: 'now' },
    last24h: { from: 'now-24h', to: 'now' },
    last7d: { from: 'now-7d', to: 'now' },
    last30d: { from: 'now-30d', to: 'now' },
  },

  // Common refresh intervals
  refreshIntervals:: {
    off: '',
    '5s': '5s',
    '10s': '10s',
    '30s': '30s',
    '1m': '1m',
    '5m': '5m',
    '10m': '10m',
    '30m': '30m',
    '1h': '1h',
  },

  // Dashboard defaults
  defaults:: {
    dashboard: {
      editable: true,
      refresh: '10m',
      timezone: 'browser',
      timeRange: { from: 'now-6h', to: 'now' },
    },
    panel: {
      height: 8,
      width: 12,
    },
  },
}
