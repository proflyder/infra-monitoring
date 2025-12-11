local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

local loki = common.datasources.loki;

common.defaultDashboard(
  'Currency Bot Logs',
  tags=['logs', 'currency-bot'],
  uid='currency-bot-logs'
)
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    // Application Logs
    common.defaultLogs('Application Logs', loki)
    + g.panel.logs.queryOptions.withTargets([
      g.query.loki.new(
        loki.uid,
        '{job="currency-bot"}'
      )
      + g.query.loki.withRefId('A'),
    ])
    + g.panel.logs.gridPos.withW(24)
    + g.panel.logs.gridPos.withH(20),

    // Logs by Level
    common.defaultTimeseries('Logs by Level (rate)', loki)
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.loki.new(
        loki.uid,
        'sum by (level) (count_over_time({job="currency-bot", level!=""} [$__interval]))'
      )
      + g.query.loki.withLegendFormat('{{level}}')
      + g.query.loki.withRefId('A'),
    ])
    + g.panel.timeSeries.fieldConfig.defaults.custom.withShowPoints('auto')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8),

    // Error Logs Only
    common.defaultLogs('Error Logs Only', loki)
    + g.panel.logs.queryOptions.withTargets([
      g.query.loki.new(
        loki.uid,
        '{job="currency-bot", level="ERROR"}'
      )
      + g.query.loki.withRefId('A'),
    ])
    + g.panel.logs.gridPos.withW(12)
    + g.panel.logs.gridPos.withH(8),

    // Incoming API Logs
    common.defaultLogs('Incoming API Logs', loki)
    + g.panel.logs.queryOptions.withTargets([
      g.query.loki.new(
        loki.uid,
        '{job="currency-bot", direction="incoming"}'
      )
      + g.query.loki.withRefId('A'),
    ])
    + g.panel.logs.gridPos.withW(12)
    + g.panel.logs.gridPos.withH(10),

    // Outgoing API Logs
    common.defaultLogs('Outgoing API Logs', loki)
    + g.panel.logs.queryOptions.withTargets([
      g.query.loki.new(
        loki.uid,
        '{job="currency-bot", direction="outgoing"}'
      )
      + g.query.loki.withRefId('A'),
    ])
    + g.panel.logs.gridPos.withW(12)
    + g.panel.logs.gridPos.withH(10),
  ], panelWidth=12, panelHeight=8, startY=0)
)
