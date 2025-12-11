local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

local loki = common.datasources.loki;

common.defaultDashboard(
  'Currency Bot - API Requests',
  tags=['api', 'requests', 'currency-bot'],
  uid='currency-bot-api'
)
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    // Incoming API Requests
    common.defaultTimeseries('Incoming API Requests (by Endpoint)', loki)
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.loki.new(
        loki.uid,
        'sum by (endpoint) (count_over_time({job="currency-bot"} | json | direction="incoming" | endpoint != "" | __error__="" [$__interval]))'
      )
      + g.query.loki.withLegendFormat('{{endpoint}}')
      + g.query.loki.withRefId('A'),
    ])
    + g.panel.timeSeries.options.legend.withDisplayMode('table')
    + g.panel.timeSeries.options.legend.withPlacement('right')
    + g.panel.timeSeries.standardOptions.withUnit('short')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withSpanNulls(true)
    + g.panel.timeSeries.fieldConfig.defaults.custom.withInsertNulls(false)
    + g.panel.timeSeries.fieldConfig.defaults.custom.withShowPoints('auto')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withPointSize(5)
    + g.panel.timeSeries.gridPos.withW(24)
    + g.panel.timeSeries.gridPos.withH(10),

    // Outgoing API Requests
    common.defaultTimeseries('Outgoing API Requests (by Service/URL)', loki)
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.loki.new(
        loki.uid,
        'sum by (service, http_url) (count_over_time({job="currency-bot"} | json | direction="outgoing" | service != "" | __error__="" [$__interval]))'
      )
      + g.query.loki.withLegendFormat('{{service}} - {{http_url}}')
      + g.query.loki.withRefId('A'),
    ])
    + g.panel.timeSeries.options.legend.withDisplayMode('table')
    + g.panel.timeSeries.options.legend.withPlacement('right')
    + g.panel.timeSeries.standardOptions.withUnit('short')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withSpanNulls(true)
    + g.panel.timeSeries.fieldConfig.defaults.custom.withInsertNulls(false)
    + g.panel.timeSeries.fieldConfig.defaults.custom.withShowPoints('auto')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withPointSize(5)
    + g.panel.timeSeries.gridPos.withW(24)
    + g.panel.timeSeries.gridPos.withH(10),
  ], panelWidth=24, panelHeight=10, startY=0)
)
