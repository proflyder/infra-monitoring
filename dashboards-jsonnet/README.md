# Grafana Dashboards - Jsonnet + Grafonnet

Модульная библиотека для создания Grafana дашбордов.

## Структура

```
lib/
├── core.libsonnet           # Datasources, thresholds
├── colors.libsonnet         # Цветовые схемы
├── units.libsonnet          # Единицы измерения
├── layouts.libsonnet        # Grid positioning
├── panels.libsonnet         # Panel factories
├── dashboards.libsonnet     # Dashboard templates
├── queries/
│   ├── prometheus.libsonnet # Prometheus query builders
│   └── loki.libsonnet       # Loki query builders
└── common.libsonnet         # Main entry point
```

## Quick Start

```jsonnet
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

local dashboards = common.dashboards;
local panels = common.panels;
local layouts = common.layouts;

dashboards.system('VM Metrics', uid='vm-metrics', tags=['system'])
+ g.dashboard.withPanels(
  layouts.grid([
    layouts.halfWidth(panels.system.cpuGauge(), height=8),
    layouts.halfWidth(panels.system.memoryGauge(), height=8),
    layouts.halfWidth(panels.system.cpuTimeseries(), height=10),
    layouts.halfWidth(panels.system.memoryTimeseries(), height=10),
  ])
)
```

## API Reference

### Panels

```jsonnet
// System
panels.system.cpuGauge()
panels.system.memoryGauge()
panels.system.cpuTimeseries()
panels.system.memoryTimeseries()

// Currency
panels.currency.rateTimeseries(title, from, to)
panels.currency.rateStat(title, from, to)
panels.currency.rateHistoryTable(title, limit)

// API
panels.api.incomingRequests(title, job)
panels.api.outgoingRequests(title, job)

// Logs
panels.logs.all(title, job)
panels.logs.byLevelTimeseries(title, job)
panels.logs.errors(title, job)
panels.logs.incoming(title, job)
panels.logs.outgoing(title, job)
```

### Layouts

```jsonnet
layouts.fullWidth(panel, height)    // 24 cols
layouts.halfWidth(panel, height)    // 12 cols
layouts.thirdWidth(panel, height)   // 8 cols
layouts.quarterWidth(panel, height) // 6 cols

layouts.grid(panels, width, height)
layouts.twoColumns(left, right)
```

### Query Builders

```jsonnet
// Prometheus
queries.prometheus.cpu.usage()
queries.prometheus.memory.usagePercent()
queries.prometheus.disk.usagePercent('/')

// Loki
queries.loki.byLevel(job, level)
queries.loki.countByLevel(job)
queries.loki.api.incomingCount(job)
queries.loki.currency.rate(job, from, to, field)
```

### Dashboards

```jsonnet
dashboards.system(title, uid, tags)
dashboards.service(title, uid, tags)
dashboards.logs(title, uid, tags)
dashboards.api(title, uid, tags)
dashboards.currency(title, uid, tags)
```

## Установка и сборка

```bash
# Установка зависимостей
./scripts/setup-jsonnet.sh
# или
make install-deps

# Сборка дашбордов
make dashboards

# Валидация
make validate

# Очистка
make clean
```

## Docker build (без локальной установки)

```bash
make dashboards-docker
```

## Добавление нового дашборда

1. Создайте `.jsonnet` файл в нужной директории
2. Используйте готовые панели и layouts
3. Запустите `make dashboards`
4. Коммитьте только `.jsonnet` файлы (JSON генерируется в CI)

Полная документация: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
