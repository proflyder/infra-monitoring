local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local core = import './core.libsonnet';

{
  // Base dashboard builder with common settings
  new:: function(title, uid='', tags=[], timeRange=core.defaults.dashboard.timeRange, refresh=core.defaults.dashboard.refresh)
    g.dashboard.new(title)
    + g.dashboard.withUid(uid)
    + g.dashboard.withTags(tags)
    + g.dashboard.withEditable(core.defaults.dashboard.editable)
    + g.dashboard.withRefresh(refresh)
    + g.dashboard.time.withFrom(timeRange.from)
    + g.dashboard.time.withTo(timeRange.to)
    + g.dashboard.withTimezone(core.defaults.dashboard.timezone)
    + g.dashboard.graphTooltip.withSharedCrosshair(),

  // System infrastructure dashboard template
  system:: function(title='VM - System Metrics', uid='vm-system-metrics', tags=['system', 'metrics'])
    $.new(title, uid, tags),

  // Service dashboard template (for application services)
  service:: function(title, uid, tags=[], serviceName='')
    local allTags = if serviceName != '' then tags + [serviceName] else tags;
    $.new(title, uid, allTags),

  // Logs dashboard template
  logs:: function(title, uid, tags=[])
    $.new(title, uid, tags + ['logs'])
    + g.dashboard.withTimezone('browser'),

  // API/monitoring dashboard template
  api:: function(title, uid, tags=[])
    $.new(title, uid, tags + ['api']),

  // Currency-specific dashboard template
  currency:: function(title='Currency Bot - Exchange Rates', uid='currency-bot-rates', tags=['currency', 'rates'])
    $.new(title, uid, tags),

  // Dashboard with template variables
  withVariables:: function(dashboard, variables)
    dashboard
    + g.dashboard.withVariables(variables),

  // Common template variables
  variables:: {
    // Datasource variable for Prometheus
    prometheusDatasource:: function(name='datasource', label='Data Source')
      g.dashboard.variable.datasource.new(name, 'prometheus')
      + g.dashboard.variable.datasource.withLabel(label)
      + g.dashboard.variable.datasource.generalOptions.withCurrent('prometheus'),

    // Datasource variable for Loki
    lokiDatasource:: function(name='datasource', label='Data Source')
      g.dashboard.variable.datasource.new(name, 'loki')
      + g.dashboard.variable.datasource.withLabel(label)
      + g.dashboard.variable.datasource.generalOptions.withCurrent('loki'),

    // Query variable
    query:: function(name, label, query, datasource, multi=false, includeAll=false)
      g.dashboard.variable.query.new(name)
      + g.dashboard.variable.query.withLabel(label)
      + g.dashboard.variable.query.queryTypes.withQuery(query)
      + g.dashboard.variable.query.withDatasource(datasource.type, datasource.uid)
      + g.dashboard.variable.query.selectionOptions.withMulti(multi)
      + g.dashboard.variable.query.selectionOptions.withIncludeAll(includeAll),

    // Interval variable
    interval:: function(name='interval', label='Interval', values=['1m', '5m', '10m', '30m', '1h'], auto=true)
      g.dashboard.variable.interval.new(name)
      + g.dashboard.variable.interval.withLabel(label)
      + g.dashboard.variable.interval.withValues(values)
      + g.dashboard.variable.interval.generalOptions.withCurrent('5m'),

    // Custom variable
    custom:: function(name, label, values, current=null)
      g.dashboard.variable.custom.new(name)
      + g.dashboard.variable.custom.withLabel(label)
      + g.dashboard.variable.custom.withValues(values)
      + (if current != null then g.dashboard.variable.custom.generalOptions.withCurrent(current) else {}),
  },

  // Dashboard annotations
  annotations:: {
    // Deployment annotations from Prometheus
    deployments:: function()
      g.dashboard.annotation.prometheus.new('Deployments')
      + g.dashboard.annotation.prometheus.withDatasource('prometheus', 'prometheus')
      + g.dashboard.annotation.prometheus.withExpr('deployment_event{} == 1')
      + g.dashboard.annotation.prometheus.withTagKeys('version')
      + g.dashboard.annotation.prometheus.withTitleFormat('Deployment')
      + g.dashboard.annotation.prometheus.withTextFormat('Version: {{version}}')
      + g.dashboard.annotation.prometheus.withIconColor('blue'),
  },

  // Add panels to dashboard using grid layout
  withPanels:: function(dashboard, panels)
    dashboard
    + g.dashboard.withPanels(panels),

  // Add single panel to dashboard
  withPanel:: function(dashboard, panel)
    dashboard
    + g.dashboard.withPanels([panel]),
}
