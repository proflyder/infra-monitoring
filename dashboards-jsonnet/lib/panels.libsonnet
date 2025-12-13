local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local core = import './core.libsonnet';
local colors = import './colors.libsonnet';
local units = import './units.libsonnet';
local promQueries = import './queries/prometheus.libsonnet';
local lokiQueries = import './queries/loki.libsonnet';

local prometheus = core.datasources.prometheus;
local loki = core.datasources.loki;

{
  // Base panel builders
  base:: {
    // Base timeseries panel
    timeseries:: function(title, datasource=prometheus)
      g.panel.timeSeries.new(title)
      + g.panel.timeSeries.datasource.withType(datasource.type)
      + g.panel.timeSeries.datasource.withUid(datasource.uid)
      + g.panel.timeSeries.options.legend.withDisplayMode('list')
      + g.panel.timeSeries.options.legend.withPlacement('bottom')
      + g.panel.timeSeries.options.legend.withCalcs(['mean', 'last', 'max'])
      + g.panel.timeSeries.options.tooltip.withMode('multi')
      + g.panel.timeSeries.options.tooltip.withSort('desc')
      + g.panel.timeSeries.fieldConfig.defaults.custom.withDrawStyle('line')
      + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
      + g.panel.timeSeries.fieldConfig.defaults.custom.withLineWidth(2)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withShowPoints('never'),

    // Base gauge panel
    gauge:: function(title, datasource=prometheus)
      g.panel.gauge.new(title)
      + g.panel.gauge.datasource.withType(datasource.type)
      + g.panel.gauge.datasource.withUid(datasource.uid)
      + g.panel.gauge.options.withOrientation('auto')
      + g.panel.gauge.options.reduceOptions.withValues(false)
      + g.panel.gauge.options.reduceOptions.withCalcs(['lastNotNull'])
      + g.panel.gauge.options.withShowThresholdLabels(false)
      + g.panel.gauge.options.withShowThresholdMarkers(true),

    // Base stat panel
    stat:: function(title, datasource=prometheus)
      g.panel.stat.new(title)
      + g.panel.stat.datasource.withType(datasource.type)
      + g.panel.stat.datasource.withUid(datasource.uid)
      + g.panel.stat.options.reduceOptions.withValues(false)
      + g.panel.stat.options.reduceOptions.withCalcs(['lastNotNull'])
      + g.panel.stat.options.withOrientation('auto')
      + g.panel.stat.options.withTextMode('value_and_name')
      + g.panel.stat.options.withColorMode('background')
      + g.panel.stat.options.withGraphMode('none'),

    // Base logs panel
    logs:: function(title, datasource=loki)
      g.panel.logs.new(title)
      + g.panel.logs.datasource.withType(datasource.type)
      + g.panel.logs.datasource.withUid(datasource.uid)
      + g.panel.logs.options.withShowTime(true)
      + g.panel.logs.options.withShowLabels(false)
      + g.panel.logs.options.withShowCommonLabels(false)
      + g.panel.logs.options.withWrapLogMessage(true)
      + g.panel.logs.options.withPrettifyLogMessage(false)
      + g.panel.logs.options.withEnableLogDetails(true)
      + g.panel.logs.options.withDedupStrategy('none')
      + g.panel.logs.options.withSortOrder('Descending'),

    // Base table panel
    table:: function(title, datasource=loki)
      g.panel.table.new(title)
      + g.panel.table.datasource.withType(datasource.type)
      + g.panel.table.datasource.withUid(datasource.uid)
      + g.panel.table.options.withShowHeader(true),
  },

  // System metrics panels
  system:: {
    // CPU gauge
    cpuGauge:: function(title='CPU Usage (%)')
      $.base.gauge(title, prometheus)
      + g.panel.gauge.queryOptions.withTargets([
        promQueries.cpu.usage(),
      ])
      + g.panel.gauge.standardOptions.withUnit(units.percentage.percent)
      + g.panel.gauge.standardOptions.withMin(0)
      + g.panel.gauge.standardOptions.withMax(100)
      + g.panel.gauge.standardOptions.thresholds.withMode('absolute')
      + g.panel.gauge.standardOptions.thresholds.withSteps(core.thresholds.cpu.steps),

    // Memory gauge
    memoryGauge:: function(title='Memory Usage (%)')
      $.base.gauge(title, prometheus)
      + g.panel.gauge.queryOptions.withTargets([
        promQueries.memory.usagePercent(),
      ])
      + g.panel.gauge.standardOptions.withUnit(units.percentage.percent)
      + g.panel.gauge.standardOptions.withMin(0)
      + g.panel.gauge.standardOptions.withMax(100)
      + g.panel.gauge.standardOptions.thresholds.withMode('absolute')
      + g.panel.gauge.standardOptions.thresholds.withSteps(core.thresholds.memory.steps),

    // CPU timeseries with modes
    cpuTimeseries:: function(title='CPU Usage Over Time (%)')
      $.base.timeseries(title, prometheus)
      + g.panel.timeSeries.queryOptions.withTargets([
        promQueries.cpu.usage(legendFormat='Total CPU Usage', refId='A'),
        promQueries.cpu.user(refId='B'),
        promQueries.cpu.system(refId='C'),
        promQueries.cpu.iowait(refId='D'),
      ])
      + g.panel.timeSeries.standardOptions.withUnit(units.percentage.percent)
      + g.panel.timeSeries.standardOptions.withMin(0)
      + g.panel.timeSeries.standardOptions.withMax(100),

    // Memory timeseries
    memoryTimeseries:: function(title='Memory Usage Over Time (GB)')
      $.base.timeseries(title, prometheus)
      + g.panel.timeSeries.queryOptions.withTargets([
        promQueries.memory.usedGB(refId='A'),
        promQueries.memory.totalGB(refId='B'),
      ])
      + g.panel.timeSeries.standardOptions.withUnit(units.data.decimalGigabytes),
  },

  // Currency panels
  currency:: {
    // Currency rate timeseries
    rateTimeseries:: function(title, currencyFrom, currencyTo, job='currency-bot')
      $.base.timeseries(title, loki)
      + g.panel.timeSeries.queryOptions.withTargets([
        lokiQueries.currency.rate(job, currencyFrom, currencyTo, 'rate_buy', '$__interval', 'Buy Rate', 'A'),
        lokiQueries.currency.rate(job, currencyFrom, currencyTo, 'rate_sell', '$__interval', 'Sell Rate', 'B'),
      ])
      + g.panel.timeSeries.options.legend.withCalcs(['mean', 'last', 'max', 'min'])
      + g.panel.timeSeries.options.tooltip.withSort('none')
      + g.panel.timeSeries.standardOptions.withUnit(units.numeric.short)
      + g.panel.timeSeries.standardOptions.withDecimals(2)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withShowPoints('always')
      + g.panel.timeSeries.fieldConfig.defaults.custom.withSpanNulls(true)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withInsertNulls(false)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withPointSize(5)
      + g.panel.timeSeries.standardOptions.withOverrides(colors.currencyOverrides),

    // Currency rate stat
    rateStat:: function(title, currencyFrom, currencyTo, job='currency-bot')
      $.base.stat(title, loki)
      + g.panel.stat.queryOptions.withTargets([
        lokiQueries.currency.latestRate(job, currencyFrom, currencyTo, 'rate_buy', 'Buy', 'A'),
        lokiQueries.currency.latestRate(job, currencyFrom, currencyTo, 'rate_sell', 'Sell', 'B'),
      ])
      + g.panel.stat.standardOptions.color.withMode('thresholds')
      + g.panel.stat.standardOptions.thresholds.withMode('absolute')
      + g.panel.stat.standardOptions.thresholds.withSteps([
        { value: null, color: colors.base.blue },
      ])
      + g.panel.stat.standardOptions.withOverrides(colors.currencyOverrides),

    // Currency rate history table
    rateHistoryTable:: function(title='Currency Rate History', limit=10, job='currency-bot')
      $.base.table(title, loki)
      + g.panel.table.queryOptions.withTargets([
        lokiQueries.currency.rateHistory(job, 'A'),
      ])
      + g.panel.table.queryOptions.withTransformations([
        {
          id: 'limit',
          options: {
            limitField: limit,
          },
        },
      ]),
  },

  // API panels
  api:: {
    // Incoming API requests timeseries
    incomingRequests:: function(title='Incoming API Requests (by Endpoint)', job='currency-bot')
      $.base.timeseries(title, loki)
      + g.panel.timeSeries.queryOptions.withTargets([
        lokiQueries.api.incomingCount(job, '$__interval', '{{endpoint}}', 'A'),
      ])
      + g.panel.timeSeries.options.legend.withDisplayMode('table')
      + g.panel.timeSeries.options.legend.withPlacement('right')
      + g.panel.timeSeries.standardOptions.withUnit(units.numeric.short)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withSpanNulls(true)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withInsertNulls(false)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withShowPoints('auto')
      + g.panel.timeSeries.fieldConfig.defaults.custom.withPointSize(5),

    // Outgoing API requests timeseries
    outgoingRequests:: function(title='Outgoing API Requests (by Service/URL)', job='currency-bot')
      $.base.timeseries(title, loki)
      + g.panel.timeSeries.queryOptions.withTargets([
        lokiQueries.api.outgoingCount(job, '$__interval', '{{service}} - {{http_url}}', 'A'),
      ])
      + g.panel.timeSeries.options.legend.withDisplayMode('table')
      + g.panel.timeSeries.options.legend.withPlacement('right')
      + g.panel.timeSeries.standardOptions.withUnit(units.numeric.short)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withSpanNulls(true)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withInsertNulls(false)
      + g.panel.timeSeries.fieldConfig.defaults.custom.withShowPoints('auto')
      + g.panel.timeSeries.fieldConfig.defaults.custom.withPointSize(5),
  },

  // Logs panels
  logs:: {
    // All application logs
    all:: function(title='Application Logs', job='currency-bot')
      $.base.logs(title, loki)
      + g.panel.logs.queryOptions.withTargets([
        lokiQueries.logs(job, {}, 'A'),
      ]),

    // Logs by level timeseries
    byLevelTimeseries:: function(title='Logs by Level (rate)', job='currency-bot')
      $.base.timeseries(title, loki)
      + g.panel.timeSeries.queryOptions.withTargets([
        lokiQueries.countByLevel(job, '$__interval', '{{level}}', 'A'),
      ])
      + g.panel.timeSeries.fieldConfig.defaults.custom.withShowPoints('auto'),

    // Error logs only
    errors:: function(title='Error Logs Only', job='currency-bot')
      $.base.logs(title, loki)
      + g.panel.logs.queryOptions.withTargets([
        lokiQueries.errors(job, 'A'),
      ]),

    // Incoming API logs
    incoming:: function(title='Incoming API Logs', job='currency-bot')
      $.base.logs(title, loki)
      + g.panel.logs.queryOptions.withTargets([
        lokiQueries.byDirection(job, 'incoming', 'A'),
      ]),

    // Outgoing API logs
    outgoing:: function(title='Outgoing API Logs', job='currency-bot')
      $.base.logs(title, loki)
      + g.panel.logs.queryOptions.withTargets([
        lokiQueries.byDirection(job, 'outgoing', 'A'),
      ]),
  },
}
