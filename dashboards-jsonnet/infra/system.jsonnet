local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

local prometheus = common.datasources.prometheus;

common.defaultDashboard(
  'VM - System Metrics',
  tags=['system', 'metrics', 'currency-bot'],
  uid='vm-system-metrics'
)
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    // CPU Usage Gauge
    common.defaultGauge('CPU Usage (%)', prometheus)
    + g.panel.gauge.queryOptions.withTargets([
      g.query.prometheus.new(
        prometheus.uid,
        '100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)'
      )
      + g.query.prometheus.withLegendFormat('CPU Usage'),
    ])
    + g.panel.gauge.standardOptions.withUnit('percent')
    + g.panel.gauge.standardOptions.withMin(0)
    + g.panel.gauge.standardOptions.withMax(100)
    + g.panel.gauge.standardOptions.thresholds.withMode('absolute')
    + g.panel.gauge.standardOptions.thresholds.withSteps(common.thresholds.cpu.steps)
    + g.panel.gauge.gridPos.withW(12)
    + g.panel.gauge.gridPos.withH(8),

    // Memory Usage Gauge
    common.defaultGauge('Memory Usage (%)', prometheus)
    + g.panel.gauge.queryOptions.withTargets([
      g.query.prometheus.new(
        prometheus.uid,
        '(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100'
      )
      + g.query.prometheus.withLegendFormat('Memory Usage'),
    ])
    + g.panel.gauge.standardOptions.withUnit('percent')
    + g.panel.gauge.standardOptions.withMin(0)
    + g.panel.gauge.standardOptions.withMax(100)
    + g.panel.gauge.standardOptions.thresholds.withMode('absolute')
    + g.panel.gauge.standardOptions.thresholds.withSteps(common.thresholds.memory.steps)
    + g.panel.gauge.gridPos.withW(12)
    + g.panel.gauge.gridPos.withH(8),

    // CPU Usage Over Time
    common.defaultTimeseries('CPU Usage Over Time (%)', prometheus)
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        prometheus.uid,
        '100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)'
      )
      + g.query.prometheus.withLegendFormat('Total CPU Usage')
      + g.query.prometheus.withRefId('A'),

      g.query.prometheus.new(
        prometheus.uid,
        'avg by (instance) (rate(node_cpu_seconds_total{mode="user"}[5m])) * 100'
      )
      + g.query.prometheus.withLegendFormat('User')
      + g.query.prometheus.withRefId('B'),

      g.query.prometheus.new(
        prometheus.uid,
        'avg by (instance) (rate(node_cpu_seconds_total{mode="system"}[5m])) * 100'
      )
      + g.query.prometheus.withLegendFormat('System')
      + g.query.prometheus.withRefId('C'),

      g.query.prometheus.new(
        prometheus.uid,
        'avg by (instance) (rate(node_cpu_seconds_total{mode="iowait"}[5m])) * 100'
      )
      + g.query.prometheus.withLegendFormat('IO Wait')
      + g.query.prometheus.withRefId('D'),
    ])
    + g.panel.timeSeries.standardOptions.withUnit('percent')
    + g.panel.timeSeries.standardOptions.withMin(0)
    + g.panel.timeSeries.standardOptions.withMax(100)
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(10),

    // Memory Usage Over Time
    common.defaultTimeseries('Memory Usage Over Time (GB)', prometheus)
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        prometheus.uid,
        '(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / 1024 / 1024 / 1024'
      )
      + g.query.prometheus.withLegendFormat('Used Memory')
      + g.query.prometheus.withRefId('A'),

      g.query.prometheus.new(
        prometheus.uid,
        'node_memory_MemTotal_bytes / 1024 / 1024 / 1024'
      )
      + g.query.prometheus.withLegendFormat('Total Memory')
      + g.query.prometheus.withRefId('B'),
    ])
    + g.panel.timeSeries.standardOptions.withUnit('decgbytes')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(10),
  ], panelWidth=12, panelHeight=8, startY=0)
)
