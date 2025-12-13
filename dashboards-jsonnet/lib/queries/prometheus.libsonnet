local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local core = import '../core.libsonnet';

local prometheus = core.datasources.prometheus;

{
  // Base query builder
  new:: function(expr, legendFormat='', refId='A', datasourceUid=prometheus.uid)
    g.query.prometheus.new(datasourceUid, expr)
    + g.query.prometheus.withLegendFormat(legendFormat)
    + g.query.prometheus.withRefId(refId),

  // Query with instant flag
  instant:: function(expr, legendFormat='', refId='A')
    $.new(expr, legendFormat, refId)
    + g.query.prometheus.withInstant(true),

  // Query with range
  range:: function(expr, legendFormat='', refId='A', step='')
    $.new(expr, legendFormat, refId)
    + g.query.prometheus.withInterval(step),

  // Rate helper
  rate:: function(metric, interval='5m', legendFormat='', refId='A')
    $.new('rate(%s[%s])' % [metric, interval], legendFormat, refId),

  // Increase helper
  increase:: function(metric, interval='5m', legendFormat='', refId='A')
    $.new('increase(%s[%s])' % [metric, interval], legendFormat, refId),

  // Irate helper (instant rate)
  irate:: function(metric, interval='5m', legendFormat='', refId='A')
    $.new('irate(%s[%s])' % [metric, interval], legendFormat, refId),

  // Sum aggregation
  sum:: function(expr, by=[], legendFormat='', refId='A')
    local byClause = if std.length(by) > 0 then ' by (%s)' % std.join(', ', by) else '';
    $.new('sum%s (%s)' % [byClause, expr], legendFormat, refId),

  // Avg aggregation
  avg:: function(expr, by=[], legendFormat='', refId='A')
    local byClause = if std.length(by) > 0 then ' by (%s)' % std.join(', ', by) else '';
    $.new('avg%s (%s)' % [byClause, expr], legendFormat, refId),

  // Max aggregation
  max:: function(expr, by=[], legendFormat='', refId='A')
    local byClause = if std.length(by) > 0 then ' by (%s)' % std.join(', ', by) else '';
    $.new('max%s (%s)' % [byClause, expr], legendFormat, refId),

  // Min aggregation
  min:: function(expr, by=[], legendFormat='', refId='A')
    local byClause = if std.length(by) > 0 then ' by (%s)' % std.join(', ', by) else '';
    $.new('min%s (%s)' % [byClause, expr], legendFormat, refId),

  // CPU usage queries
  cpu:: {
    // Total CPU usage (100 - idle)
    usage:: function(interval='5m', legendFormat='CPU Usage', refId='A')
      $.new(
        '100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[%s])) * 100)' % interval,
        legendFormat,
        refId
      ),

    // CPU usage by mode
    usageByMode:: function(mode, interval='5m', legendFormat='{{mode}}', refId='A')
      $.new(
        'avg by (instance) (rate(node_cpu_seconds_total{mode="%s"}[%s])) * 100' % [mode, interval],
        legendFormat,
        refId
      ),

    // User CPU
    user:: function(interval='5m', refId='B')
      $.cpu.usageByMode('user', interval, 'User', refId),

    // System CPU
    system:: function(interval='5m', refId='C')
      $.cpu.usageByMode('system', interval, 'System', refId),

    // IO Wait
    iowait:: function(interval='5m', refId='D')
      $.cpu.usageByMode('iowait', interval, 'IO Wait', refId),
  },

  // Memory usage queries
  memory:: {
    // Memory usage in bytes
    usedBytes:: function(legendFormat='Used Memory', refId='A')
      $.new(
        'node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes',
        legendFormat,
        refId
      ),

    // Memory usage in GB
    usedGB:: function(legendFormat='Used Memory', refId='A')
      $.new(
        '(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / 1024 / 1024 / 1024',
        legendFormat,
        refId
      ),

    // Total memory in GB
    totalGB:: function(legendFormat='Total Memory', refId='B')
      $.new(
        'node_memory_MemTotal_bytes / 1024 / 1024 / 1024',
        legendFormat,
        refId
      ),

    // Memory usage percentage
    usagePercent:: function(legendFormat='Memory Usage', refId='A')
      $.new(
        '(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100',
        legendFormat,
        refId
      ),

    // Available memory in bytes
    availableBytes:: function(legendFormat='Available Memory', refId='A')
      $.new(
        'node_memory_MemAvailable_bytes',
        legendFormat,
        refId
      ),
  },

  // Disk usage queries
  disk:: {
    // Disk usage percentage
    usagePercent:: function(mountpoint='/', legendFormat='Disk Usage', refId='A')
      $.new(
        '(1 - (node_filesystem_avail_bytes{mountpoint="%s"} / node_filesystem_size_bytes{mountpoint="%s"})) * 100' % [mountpoint, mountpoint],
        legendFormat,
        refId
      ),

    // Disk used in GB
    usedGB:: function(mountpoint='/', legendFormat='Used', refId='A')
      $.new(
        '(node_filesystem_size_bytes{mountpoint="%s"} - node_filesystem_avail_bytes{mountpoint="%s"}) / 1024 / 1024 / 1024' % [mountpoint, mountpoint],
        legendFormat,
        refId
      ),

    // Disk total in GB
    totalGB:: function(mountpoint='/', legendFormat='Total', refId='B')
      $.new(
        'node_filesystem_size_bytes{mountpoint="%s"} / 1024 / 1024 / 1024' % mountpoint,
        legendFormat,
        refId
      ),
  },

  // Network queries
  network:: {
    // Network receive rate
    receiveRate:: function(interface='eth0', interval='5m', legendFormat='Receive', refId='A')
      $.new(
        'rate(node_network_receive_bytes_total{device="%s"}[%s])' % [interface, interval],
        legendFormat,
        refId
      ),

    // Network transmit rate
    transmitRate:: function(interface='eth0', interval='5m', legendFormat='Transmit', refId='B')
      $.new(
        'rate(node_network_transmit_bytes_total{device="%s"}[%s])' % [interface, interval],
        legendFormat,
        refId
      ),
  },

  // HTTP/API queries
  http:: {
    // Request rate
    requestRate:: function(job, interval='5m', legendFormat='{{method}} {{path}}', refId='A')
      $.new(
        'sum by (method, path) (rate(http_requests_total{job="%s"}[%s]))' % [job, interval],
        legendFormat,
        refId
      ),

    // Error rate
    errorRate:: function(job, interval='5m', legendFormat='Errors', refId='A')
      $.new(
        'sum(rate(http_requests_total{job="%s",status=~"5.."}[%s]))' % [job, interval],
        legendFormat,
        refId
      ),

    // Request duration (p50, p95, p99)
    durationQuantile:: function(job, quantile=0.95, interval='5m', legendFormat='p{{quantile}}', refId='A')
      $.new(
        'histogram_quantile(%s, sum by (le) (rate(http_request_duration_seconds_bucket{job="%s"}[%s])))' % [quantile, job, interval],
        legendFormat,
        refId
      ),
  },
}
