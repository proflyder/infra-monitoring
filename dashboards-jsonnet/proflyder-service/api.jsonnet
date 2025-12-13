local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

// Use new libraries
local dashboards = common.dashboards;
local panels = common.panels;
local layouts = common.layouts;

// Create API dashboard
dashboards.api(
  'Currency Bot - API Requests',
  uid='currency-bot-api',
  tags=['api', 'requests', 'currency-bot']
)
+ g.dashboard.withPanels(
  layouts.grid([
    // Incoming API requests - full width
    layouts.fullWidth(
      panels.api.incomingRequests(),
      height=10
    ),

    // Outgoing API requests - full width
    layouts.fullWidth(
      panels.api.outgoingRequests(),
      height=10
    ),
  ], panelWidth=24, panelHeight=10, startY=0)
)
