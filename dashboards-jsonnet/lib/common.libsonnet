// Common library - main entry point with backward compatibility
// This file re-exports all modular libraries and maintains the old API

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local core = import './core.libsonnet';
local colors = import './colors.libsonnet';
local units = import './units.libsonnet';
local layouts = import './layouts.libsonnet';
local panels = import './panels.libsonnet';
local dashboards = import './dashboards.libsonnet';
local promQueries = import './queries/prometheus.libsonnet';
local lokiQueries = import './queries/loki.libsonnet';

{
  // Re-export all modules for direct access
  core:: core,
  colors:: colors,
  units:: units,
  layouts:: layouts,
  panels:: panels,
  dashboards:: dashboards,
  queries:: {
    prometheus:: promQueries,
    loki:: lokiQueries,
  },

  // Grafana reference
  grafana:: g,

  // ===== BACKWARD COMPATIBILITY LAYER =====
  // Keep old API working for existing dashboards

  // Common datasources (from core)
  datasources:: core.datasources,

  // Common thresholds (from core)
  thresholds:: core.thresholds,

  // Default dashboard (backward compatible)
  defaultDashboard:: function(title, tags=[], uid='')
    dashboards.new(title, uid, tags),

  // Default timeseries panel (backward compatible)
  defaultTimeseries:: function(title, datasource)
    panels.base.timeseries(title, datasource),

  // Default gauge panel (backward compatible)
  defaultGauge:: function(title, datasource)
    panels.base.gauge(title, datasource),

  // Default logs panel (backward compatible)
  defaultLogs:: function(title, datasource)
    panels.base.logs(title, datasource),

  // Default stat panel (backward compatible)
  defaultStat:: function(title, datasource)
    panels.base.stat(title, datasource),

  // Prometheus query helper (backward compatible)
  prometheusQuery:: function(expr, legendFormat='', refId='A')
    promQueries.new(expr, legendFormat, refId),

  // Loki query helper (backward compatible)
  lokiQuery:: function(expr, legendFormat='', refId='A')
    lokiQueries.new(expr, legendFormat, refId),

  // Grid position helper (backward compatible)
  gridPos:: function(x, y, w, h)
    layouts.gridPos(x, y, w, h),
}
