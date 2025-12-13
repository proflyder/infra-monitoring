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
  layouts.grid([
    // Row 1: Gauges
    layouts.halfWidth(
      panels.system.cpuGauge(),
      height=8
    ),
    layouts.halfWidth(
      panels.system.memoryGauge(),
      height=8
    ),

    // Row 2: CPU timeseries
    layouts.halfWidth(
      panels.system.cpuTimeseries(),
      height=10
    ),

    // Row 3: Memory timeseries
    layouts.halfWidth(
      panels.system.memoryTimeseries(),
      height=10
    ),
  ], panelWidth=12, panelHeight=8, startY=0)
)
