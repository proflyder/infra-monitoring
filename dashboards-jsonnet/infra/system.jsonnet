local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

// Use new libraries
local dashboards = common.dashboards;
local panels = common.panels;
local layouts = common.layouts;

// Create system dashboard
dashboards.system(
  'VM - System Metrics',
  uid='vm-system-metrics',
  tags=['system', 'metrics', 'currency-bot']
)
+ g.dashboard.withPanels(
  [
    // Row 1: Gauges
    panels.system.cpuGauge()
    + layouts.gridPos(0, 0, 12, 8),
    panels.system.memoryGauge()
    + layouts.gridPos(12, 0, 12, 8),

    // Row 2: CPU and memory timeseries
    panels.system.cpuTimeseries()
    + layouts.gridPos(0, 8, 12, 10),
    panels.system.memoryTimeseries()
    + layouts.gridPos(12, 8, 12, 10),

    // Row 3: Disk usage
    panels.system.diskGauge('Root Disk Usage (%)', '/')
    + layouts.gridPos(0, 18, 24, 8),
  ]
)
