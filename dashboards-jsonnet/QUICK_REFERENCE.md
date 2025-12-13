# API Reference

## Импорты

```jsonnet
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

local dashboards = common.dashboards;
local panels = common.panels;
local layouts = common.layouts;
local queries = common.queries;
```

## Dashboards

```jsonnet
dashboards.system(title, uid, tags)      // VM/System dashboard
dashboards.service(title, uid, tags)     // Application service
dashboards.logs(title, uid, tags)        // Logs dashboard
dashboards.api(title, uid, tags)         // API metrics
dashboards.currency(title, uid, tags)    // Currency rates
```

## Panels

### System

```jsonnet
panels.system.cpuGauge()              // CPU gauge with thresholds
panels.system.memoryGauge()           // Memory gauge
panels.system.cpuTimeseries()         // CPU chart (all modes)
panels.system.memoryTimeseries()      // Memory chart
```

### Currency

```jsonnet
panels.currency.rateTimeseries(title, from, to, job='currency-bot')
panels.currency.rateStat(title, from, to, job='currency-bot')
panels.currency.rateHistoryTable(title='History', limit=10, job='currency-bot')
```

### API

```jsonnet
panels.api.incomingRequests(title='Incoming', job='currency-bot')
panels.api.outgoingRequests(title='Outgoing', job='currency-bot')
```

### Logs

```jsonnet
panels.logs.all(title='All Logs', job='currency-bot')
panels.logs.byLevelTimeseries(title='By Level', job='currency-bot')
panels.logs.errors(title='Errors', job='currency-bot')
panels.logs.incoming(title='Incoming', job='currency-bot')
panels.logs.outgoing(title='Outgoing', job='currency-bot')
```

### Base (generic)

```jsonnet
panels.base.timeseries(title, datasource)
panels.base.gauge(title, datasource)
panels.base.stat(title, datasource)
panels.base.logs(title, datasource)
panels.base.table(title, datasource)
```

## Layouts

```jsonnet
// Grid auto-layout
layouts.grid(panels, panelWidth=12, panelHeight=8, startY=0)

// Size helpers
layouts.fullWidth(panel, height=8)       // 24 cols
layouts.halfWidth(panel, height=8)       // 12 cols
layouts.thirdWidth(panel, height=8)      // 8 cols
layouts.quarterWidth(panel, height=8)    // 6 cols
layouts.twoThirds(panel, height=8)       // 16 cols
layouts.threeQuarters(panel, height=8)   // 18 cols
layouts.customSize(panel, width, height)

// Multi-column layouts
layouts.twoColumns(leftPanels, rightPanels, height=8)
layouts.threeColumns(col1, col2, col3, height=8)
layouts.fourColumns(col1, col2, col3, col4, height=8)

// Rows
layouts.row(title, collapsed=false)
```

## Query Builders

### Prometheus

```jsonnet
local prom = queries.prometheus;

// CPU
prom.cpu.usage(interval='5m', legendFormat='CPU Usage', refId='A')
prom.cpu.user(interval='5m', refId='B')
prom.cpu.system(interval='5m', refId='C')
prom.cpu.iowait(interval='5m', refId='D')

// Memory
prom.memory.usagePercent(legendFormat='Memory %', refId='A')
prom.memory.usedGB(legendFormat='Used', refId='A')
prom.memory.totalGB(legendFormat='Total', refId='B')
prom.memory.availableBytes(legendFormat='Available', refId='A')

// Disk
prom.disk.usagePercent(mountpoint='/', legendFormat='Disk %', refId='A')
prom.disk.usedGB(mountpoint='/', legendFormat='Used', refId='A')
prom.disk.totalGB(mountpoint='/', legendFormat='Total', refId='B')

// Network
prom.network.receiveRate(interface='eth0', interval='5m', refId='A')
prom.network.transmitRate(interface='eth0', interval='5m', refId='B')

// Generic builders
prom.new(expr, legendFormat='', refId='A')
prom.rate(metric, interval='5m', legendFormat='', refId='A')
prom.sum(expr, by=[], legendFormat='', refId='A')
prom.avg(expr, by=[], legendFormat='', refId='A')
```

### Loki

```jsonnet
local loki = queries.loki;

// Basic
loki.new(expr, legendFormat='', refId='A')
loki.logs(job, filters={}, refId='A')
loki.json(selector, filters={}, refId='A')

// By level
loki.byLevel(job, level='ERROR', refId='A')
loki.countByLevel(job, interval='$__interval', legendFormat='{{level}}', refId='A')

// By direction
loki.byDirection(job, direction='incoming', refId='A')

// API
loki.api.incomingCount(job, interval='$__interval', refId='A')
loki.api.outgoingCount(job, interval='$__interval', refId='A')

// Currency
loki.currency.rate(job, from, to, field='rate_buy', interval='$__interval', refId='A')
loki.currency.latestRate(job, from, to, field='rate_buy', refId='A')
loki.currency.rateHistory(job, refId='A')

// Aggregations
loki.countOverTime(selector, interval='$__interval', by=[], refId='A')
loki.unwrap(selector, field, aggregation='max', interval='$__interval', refId='A')
```

## Colors

```jsonnet
// Severity
colors.severity.success              // green
colors.severity.warning              // yellow
colors.severity.error                // red

// Currency
colors.currency.buy                  // green
colors.currency.sell                 // red

// System
colors.system.cpu                    // blue
colors.system.memory                 // green

// Hex colors
colors.hex.green                     // #73BF69
colors.hex.red                       // #F2495C
colors.hex.blue                      // #5794F2

// Field overrides (для панелей)
colors.currencyOverrides             // [Buy=green, Sell=red]
colors.logLevelOverrides             // [ERROR=red, WARN=yellow, ...]
colors.apiDirectionOverrides         // [incoming=blue, outgoing=purple]

// Helper
colors.fieldOverride(fieldName, color)
```

## Units

```jsonnet
// Percentage
units.percentage.percent             // %
units.percentage.percentUnit         // 0-1

// Data
units.data.bytes
units.data.decimalGigabytes          // GB
units.data.decimalMegabytes          // MB

// Time
units.time.seconds                   // s
units.time.milliseconds              // ms

// Numeric
units.numeric.short                  // k, M, B
units.numeric.ops                    // operations

// Configs with min/max
units.configs.percent                // {unit: 'percent', min: 0, max: 100}
units.configs.short                  // {unit: 'short', min: 0}
```

## Core

```jsonnet
// Datasources
core.datasources.prometheus          // {type: 'prometheus', uid: 'prometheus'}
core.datasources.loki                // {type: 'loki', uid: 'loki'}

// Thresholds
core.thresholds.cpu                  // [null=green, 70=yellow, 90=red]
core.thresholds.memory               // [null=green, 75=yellow, 90=red]
core.thresholds.disk                 // [null=green, 80=yellow, 95=red]

// Time ranges
core.timeRanges.last6h               // {from: 'now-6h', to: 'now'}
core.timeRanges.last24h              // {from: 'now-24h', to: 'now'}

// Refresh intervals
core.refreshIntervals['5m']          // '5m'
core.refreshIntervals['10m']         // '10m'
```

## Полный пример

```jsonnet
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

local dashboards = common.dashboards;
local panels = common.panels;
local layouts = common.layouts;

dashboards.currency('Currency Bot', uid='currency-bot', tags=['currency'])
+ g.dashboard.withPanels(
  layouts.grid([
    layouts.halfWidth(
      panels.currency.rateTimeseries('USD/KZT', 'USD', 'KZT'),
      height=10
    ),
    layouts.halfWidth(
      panels.currency.rateTimeseries('RUB/KZT', 'RUB', 'KZT'),
      height=10
    ),
    layouts.fullWidth(
      panels.currency.rateHistoryTable(limit=10),
      height=8
    ),
  ])
)
```

## Custom панели

```jsonnet
// Использование base панелей с кастомными queries
local prom = common.queries.prometheus;

panels.base.timeseries('Custom CPU', common.core.datasources.prometheus)
+ g.panel.timeSeries.queryOptions.withTargets([
  prom.cpu.usage(legendFormat='Total CPU', refId='A'),
])
+ g.panel.timeSeries.standardOptions.withUnit(common.units.percentage.percent)
+ layouts.halfWidth(height=10)
```
