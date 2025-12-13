local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

// Use new libraries
local dashboards = common.dashboards;
local panels = common.panels;
local layouts = common.layouts;

// Create currency dashboard
dashboards.currency(
  'Currency Bot - Exchange Rates',
  uid='currency-bot-rates',
  tags=['currency', 'rates', 'currency-bot']
)
+ g.dashboard.withPanels(
  layouts.grid([
    // Row 1: Currency rate timeseries charts
    layouts.halfWidth(
      panels.currency.rateTimeseries('USD/KZT Exchange Rate', 'USD', 'KZT'),
      height=10
    ),
    layouts.halfWidth(
      panels.currency.rateTimeseries('RUB/KZT Exchange Rate', 'RUB', 'KZT'),
      height=10
    ),

    // Row 2: Latest rate stats
    layouts.halfWidth(
      panels.currency.rateStat('Latest USD/KZT Rates', 'USD', 'KZT'),
      height=6
    ),
    layouts.halfWidth(
      panels.currency.rateStat('Latest RUB/KZT Rates', 'RUB', 'KZT'),
      height=6
    ),

    // Row 3: Rate history table (full width)
    layouts.fullWidth(
      panels.currency.rateHistoryTable('Currency Rate History (Last 10 Updates)', limit=10),
      height=10
    ),
  ], panelWidth=12, panelHeight=8, startY=0)
)
