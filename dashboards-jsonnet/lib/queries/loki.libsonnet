local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local core = import '../core.libsonnet';

local loki = core.datasources.loki;

{
  // Base query builder
  new:: function(expr, legendFormat='', refId='A', datasourceUid=loki.uid)
    g.query.loki.new(datasourceUid, expr)
    + g.query.loki.withLegendFormat(legendFormat)
    + g.query.loki.withRefId(refId),

  // Stream selector helper
  stream:: function(labels, refId='A')
    local labelPairs = [
      '%s="%s"' % [key, labels[key]]
      for key in std.objectFields(labels)
    ];
    local selector = '{%s}' % std.join(',', labelPairs);
    $.new(selector, '', refId),

  // Log query with filters
  logs:: function(job, filters={}, refId='A')
    local baseSelector = '{job="%s"}' % job;
    local filterPipeline = std.join(' ', [
      '| %s="%s"' % [key, filters[key]]
      for key in std.objectFields(filters)
    ]);
    local query = if std.length(filters) > 0
      then '%s %s' % [baseSelector, filterPipeline]
      else baseSelector;
    $.new(query, '', refId),

  // Count over time
  countOverTime:: function(selector, interval='$__interval', by=[], legendFormat='', refId='A')
    local byClause = if std.length(by) > 0 then ' by (%s)' % std.join(', ', by) else '';
    local query = 'sum%s (count_over_time(%s [%s]))' % [byClause, selector, interval];
    $.new(query, legendFormat, refId),

  // Rate
  rate:: function(selector, interval='5m', by=[], legendFormat='', refId='A')
    local byClause = if std.length(by) > 0 then ' by (%s)' % std.join(', ', by) else '';
    local query = 'sum%s (rate(%s [%s]))' % [byClause, selector, interval];
    $.new(query, legendFormat, refId),

  // Unwrap and aggregate (for metrics extraction)
  unwrap:: function(selector, field, aggregation='max', interval='$__interval', legendFormat='', refId='A')
    local query = '%s(last_over_time(%s | unwrap %s [%s]))' % [aggregation, selector, field, interval];
    $.new(query, legendFormat, refId),

  // JSON parsing helper
  json:: function(selector, filters={}, refId='A')
    local filterPipeline = std.join(' ', [
      '| %s="%s"' % [key, filters[key]]
      for key in std.objectFields(filters)
    ]);
    local query = '%s | json%s | __error__=""' % [
      selector,
      if std.length(filters) > 0 then ' ' + filterPipeline else '',
    ];
    $.new(query, '', refId),

  // Pattern parsing helper
  pattern:: function(selector, pattern, refId='A')
    local query = '%s | pattern `%s`' % [selector, pattern];
    $.new(query, '', refId),

  // Logs by level
  byLevel:: function(job, level=null, refId='A')
    local selector = if level != null
      then '{job="%s", level="%s"}' % [job, level]
      else '{job="%s", level!=""}' % job;
    $.new(selector, '', refId),

  // Count logs by level
  countByLevel:: function(job, interval='$__interval', legendFormat='{{level}}', refId='A')
    $.countOverTime(
      '{job="%s", level!=""}' % job,
      interval,
      ['level'],
      legendFormat,
      refId
    ),

  // Logs by direction (incoming/outgoing)
  byDirection:: function(job, direction=null, refId='A')
    local selector = if direction != null
      then '{job="%s", direction="%s"}' % [job, direction]
      else '{job="%s", direction!=""}' % job;
    $.new(selector, '', refId),

  // Count by direction
  countByDirection:: function(job, interval='$__interval', legendFormat='{{direction}}', refId='A')
    $.countOverTime(
      '{job="%s", direction!=""}' % job,
      interval,
      ['direction'],
      legendFormat,
      refId
    ),

  // API-specific queries
  api:: {
    // Incoming API requests count
    incomingCount:: function(job, interval='$__interval', legendFormat='{{endpoint}}', refId='A')
      $.countOverTime(
        '{job="%s"} | json | direction="incoming" | endpoint != "" | __error__=""' % job,
        interval,
        ['endpoint'],
        legendFormat,
        refId
      ),

    // Outgoing API requests count
    outgoingCount:: function(job, interval='$__interval', legendFormat='{{service}} - {{http_url}}', refId='A')
      $.countOverTime(
        '{job="%s"} | json | direction="outgoing" | service != "" | __error__=""' % job,
        interval,
        ['service', 'http_url'],
        legendFormat,
        refId
      ),

    // API logs by endpoint
    byEndpoint:: function(job, endpoint, refId='A')
      $.json(
        '{job="%s"}' % job,
        { direction: 'incoming', endpoint: endpoint },
        refId
      ),
  },

  // Currency-specific queries
  currency:: {
    // Currency rate (unwrap from logs)
    rate:: function(job, currencyFrom, currencyTo, field='rate_buy', interval='$__interval', legendFormat='', refId='A')
      $.unwrap(
        '{job="%s",event="currency_rate_updated"} | json | currency_from="%s" | currency_to="%s"' % [job, currencyFrom, currencyTo],
        field,
        'max',
        interval,
        legendFormat,
        refId
      ),

    // Latest rate (short interval)
    latestRate:: function(job, currencyFrom, currencyTo, field='rate_buy', legendFormat='', refId='A')
      $.currency.rate(job, currencyFrom, currencyTo, field, '5m', legendFormat, refId),

    // Currency rate history
    rateHistory:: function(job, refId='A')
      $.new(
        '{job="%s",event="currency_rate_updated"} | json | line_format "{{.currency_from}}/{{.currency_to}} | Buy: {{.rate_buy}} | Sell: {{.rate_sell}}"' % job,
        '',
        refId
      ),
  },

  // Error logs
  errors:: function(job, refId='A')
    $.byLevel(job, 'ERROR', refId),

  // Warning logs
  warnings:: function(job, refId='A')
    $.byLevel(job, 'WARN', refId),

  // Line format helper
  lineFormat:: function(selector, format, refId='A')
    local query = '%s | line_format "%s"' % [selector, format];
    $.new(query, '', refId),
}
