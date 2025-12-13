local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

// Use new libraries
local dashboards = common.dashboards;
local panels = common.panels;
local layouts = common.layouts;

// Create logs dashboard
dashboards.logs(
  'Currency Bot Logs',
  uid='currency-bot-logs',
  tags=['logs', 'currency-bot']
)
+ g.dashboard.withPanels(
  layouts.grid([
    // Row 1: All application logs (full width)
    layouts.fullWidth(
      panels.logs.all(),
      height=20
    ),

    // Row 2: Logs by level chart and error logs
    layouts.halfWidth(
      panels.logs.byLevelTimeseries(),
      height=8
    ),
    layouts.halfWidth(
      panels.logs.errors(),
      height=8
    ),

    // Row 3: Incoming and outgoing API logs
    layouts.halfWidth(
      panels.logs.incoming(),
      height=10
    ),
    layouts.halfWidth(
      panels.logs.outgoing(),
      height=10
    ),
  ], panelWidth=12, panelHeight=8, startY=0)
)
