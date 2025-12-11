local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
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

  // Common dashboard settings
  defaultDashboard(title, tags=[], uid='')::
    g.dashboard.new(title)
    + g.dashboard.withUid(uid)
    + g.dashboard.withTags(tags)
    + g.dashboard.withEditable(true)
    + g.dashboard.withRefresh('10m')
    + g.dashboard.time.withFrom('now-6h')
    + g.dashboard.time.withTo('now')
    + g.dashboard.withTimezone('browser')
    + g.dashboard.graphTooltip.withSharedCrosshair(),

  // Common timeseries panel settings
  defaultTimeseries(title, datasource)::
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

  // Common gauge panel settings
  defaultGauge(title, datasource)::
    g.panel.gauge.new(title)
    + g.panel.gauge.datasource.withType(datasource.type)
    + g.panel.gauge.datasource.withUid(datasource.uid)
    + g.panel.gauge.options.withOrientation('auto')
    + g.panel.gauge.options.reduceOptions.withValues(false)
    + g.panel.gauge.options.reduceOptions.withCalcs(['lastNotNull'])
    + g.panel.gauge.options.withShowThresholdLabels(false)
    + g.panel.gauge.options.withShowThresholdMarkers(true),

  // Common logs panel settings
  defaultLogs(title, datasource)::
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

  // Common stat panel settings
  defaultStat(title, datasource)::
    g.panel.stat.new(title)
    + g.panel.stat.datasource.withType(datasource.type)
    + g.panel.stat.datasource.withUid(datasource.uid)
    + g.panel.stat.options.reduceOptions.withValues(false)
    + g.panel.stat.options.reduceOptions.withCalcs(['lastNotNull'])
    + g.panel.stat.options.withOrientation('auto')
    + g.panel.stat.options.withTextMode('value_and_name')
    + g.panel.stat.options.withColorMode('background')
    + g.panel.stat.options.withGraphMode('none'),

  // Prometheus query helper
  prometheusQuery(expr, legendFormat='', refId='A')::
    g.query.prometheus.new('$datasource', expr)
    + g.query.prometheus.withLegendFormat(legendFormat)
    + g.query.prometheus.withRefId(refId),

  // Loki query helper
  lokiQuery(expr, legendFormat='', refId='A')::
    g.query.loki.new('$datasource', expr)
    + g.query.loki.withLegendFormat(legendFormat)
    + g.query.loki.withRefId(refId),

  // Common threshold settings
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
  },

  // Grid position helper
  gridPos(x, y, w, h):: {
    gridPos: {
      x: x,
      y: y,
      w: w,
      h: h,
    },
  },
}
