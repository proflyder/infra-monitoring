local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

local loki = common.datasources.loki;

local currencyTimeseries(title, currencyFrom, currencyTo) =
  common.defaultTimeseries(title, loki)
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.loki.new(
      loki.uid,
      'max(last_over_time({job="currency-bot",event="currency_rate_updated"} | json | currency_from="%s" | currency_to="%s" | unwrap rate_buy [$__interval]))' % [currencyFrom, currencyTo]
    )
    + g.query.loki.withLegendFormat('Buy Rate')
    + g.query.loki.withRefId('A'),

    g.query.loki.new(
      loki.uid,
      'max(last_over_time({job="currency-bot",event="currency_rate_updated"} | json | currency_from="%s" | currency_to="%s" | unwrap rate_sell [$__interval]))' % [currencyFrom, currencyTo]
    )
    + g.query.loki.withLegendFormat('Sell Rate')
    + g.query.loki.withRefId('B'),
  ])
  + g.panel.timeSeries.options.legend.withCalcs(['mean', 'last', 'max', 'min'])
  + g.panel.timeSeries.options.tooltip.withSort('none')
  + g.panel.timeSeries.standardOptions.withUnit('short')
  + g.panel.timeSeries.standardOptions.withDecimals(2)
  + g.panel.timeSeries.fieldConfig.defaults.custom.withShowPoints('always')
  + g.panel.timeSeries.fieldConfig.defaults.custom.withSpanNulls(true)
  + g.panel.timeSeries.fieldConfig.defaults.custom.withInsertNulls(false)
  + g.panel.timeSeries.fieldConfig.defaults.custom.withPointSize(5)
  + g.panel.timeSeries.standardOptions.withOverrides([
    {
      matcher: { id: 'byName', options: 'Buy Rate' },
      properties: [
        { id: 'color', value: { mode: 'fixed', fixedColor: 'green' } },
      ],
    },
    {
      matcher: { id: 'byName', options: 'Sell Rate' },
      properties: [
        { id: 'color', value: { mode: 'fixed', fixedColor: 'red' } },
      ],
    },
  ]);

local currencyStat(title, currencyFrom, currencyTo) =
  common.defaultStat(title, loki)
  + g.panel.stat.queryOptions.withTargets([
    g.query.loki.new(
      loki.uid,
      'max(last_over_time({job="currency-bot",event="currency_rate_updated"} | json | currency_from="%s" | currency_to="%s" | unwrap rate_buy [5m]))' % [currencyFrom, currencyTo]
    )
    + g.query.loki.withLegendFormat('Buy')
    + g.query.loki.withRefId('A'),

    g.query.loki.new(
      loki.uid,
      'max(last_over_time({job="currency-bot",event="currency_rate_updated"} | json | currency_from="%s" | currency_to="%s" | unwrap rate_sell [5m]))' % [currencyFrom, currencyTo]
    )
    + g.query.loki.withLegendFormat('Sell')
    + g.query.loki.withRefId('B'),
  ])
  + g.panel.stat.standardOptions.color.withMode('thresholds')
  + g.panel.stat.standardOptions.thresholds.withMode('absolute')
  + g.panel.stat.standardOptions.thresholds.withSteps([
    { value: null, color: 'blue' },
  ])
  + g.panel.stat.standardOptions.withOverrides([
    {
      matcher: { id: 'byName', options: 'Buy' },
      properties: [
        { id: 'color', value: { mode: 'fixed', fixedColor: 'green' } },
      ],
    },
    {
      matcher: { id: 'byName', options: 'Sell' },
      properties: [
        { id: 'color', value: { mode: 'fixed', fixedColor: 'red' } },
      ],
    },
  ]);

common.defaultDashboard(
  'Currency Bot - Exchange Rates',
  tags=['currency', 'rates', 'currency-bot'],
  uid='currency-bot-rates'
)
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    // USD/KZT Exchange Rate
    currencyTimeseries('USD/KZT Exchange Rate', 'USD', 'KZT')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(10),

    // RUB/KZT Exchange Rate
    currencyTimeseries('RUB/KZT Exchange Rate', 'RUB', 'KZT')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(10),

    // Latest USD/KZT Rates
    currencyStat('Latest USD/KZT Rates', 'USD', 'KZT')
    + g.panel.stat.gridPos.withW(12)
    + g.panel.stat.gridPos.withH(6),

    // Latest RUB/KZT Rates
    currencyStat('Latest RUB/KZT Rates', 'RUB', 'KZT')
    + g.panel.stat.gridPos.withW(12)
    + g.panel.stat.gridPos.withH(6),

    // Currency Rate History Table
    g.panel.table.new('Currency Rate History (Last 10 Updates)')
    + g.panel.table.datasource.withType(loki.type)
    + g.panel.table.datasource.withUid(loki.uid)
    + g.panel.table.queryOptions.withTargets([
      g.query.loki.new(
        loki.uid,
        '{job="currency-bot",event="currency_rate_updated"} | json | line_format "{{.currency_from}}/{{.currency_to}} | Buy: {{.rate_buy}} | Sell: {{.rate_sell}}"'
      )
      + g.query.loki.withRefId('A'),
    ])
    + g.panel.table.options.withShowHeader(true)
    + g.panel.table.queryOptions.withTransformations([
      {
        id: 'limit',
        options: {
          limitField: 10,
        },
      },
    ])
    + g.panel.table.gridPos.withW(24)
    + g.panel.table.gridPos.withH(10),
  ], panelWidth=12, panelHeight=8, startY=0)
)
