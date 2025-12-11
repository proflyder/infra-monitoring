# Grafana Dashboards using Jsonnet + Grafonnet

Этот проект использует [Jsonnet](https://jsonnet.org/) и [Grafonnet](https://github.com/grafana/grafonnet) для программного создания дашбордов Grafana.

## Преимущества

- **Переиспользование кода**: Общие компоненты и функции в `lib/common.libsonnet`
- **Читаемость**: Компактный код вместо многостраничных JSON файлов
- **DRY principle**: Не повторяйся - создавай функции для повторяющихся паттернов
- **Параметризация**: Легко создавать похожие дашборды с разными параметрами
- **Git-friendly**: Осмысленные diff'ы в git вместо огромных JSON изменений

## Установка

### Быстрая установка (macOS/Linux)

```bash
./scripts/setup-jsonnet.sh
```

### Ручная установка

#### macOS
```bash
brew install jsonnet jsonnet-bundler
```

#### Ubuntu/Debian
```bash
sudo apt-get install jsonnet
# jsonnet-bundler нужно установить через Go
go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
```

#### Установка зависимостей
```bash
jb install
```

Это установит grafonnet библиотеку в директорию `vendor/`.

## Структура проекта

```
dashboards-jsonnet/
├── lib/
│   └── common.libsonnet       # Общие компоненты и helpers
├── infra/
│   └── system.jsonnet         # VM System Metrics dashboard
└── proflyder-service/
    ├── api.jsonnet            # API Requests dashboard
    ├── logs.jsonnet           # Logs dashboard
    └── currency.jsonnet       # Exchange Rates dashboard
```

## Использование

### Собрать все дашборды

```bash
make dashboards
```

Это сгенерирует JSON файлы в `config/grafana/dashboards/`.

### Собрать конкретный дашборд

```bash
jsonnet -J vendor dashboards-jsonnet/infra/system.jsonnet -o config/grafana/dashboards/infra/system.json
```

### Валидация

```bash
make validate
```

### Очистка сгенерированных файлов

```bash
make clean
```

### Watch mode (автоматическая пересборка)

```bash
make watch
```

Требует установки `entr`:
```bash
brew install entr
```

## Разработка дашбордов

### Базовый пример

```jsonnet
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

local prometheus = common.datasources.prometheus;

common.defaultDashboard(
  'My Dashboard',
  tags=['my-tag'],
  uid='my-dashboard'
)
+ g.dashboard.withPanels([
  common.defaultTimeseries('My Panel', prometheus)
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new(
      prometheus.uid,
      'my_metric'
    )
    + g.query.prometheus.withLegendFormat('My Metric'),
  ])
  + g.panel.timeSeries.gridPos.withW(12)
  + g.panel.timeSeries.gridPos.withH(8),
])
```

### Доступные компоненты в common.libsonnet

#### Datasources
- `common.datasources.prometheus` - Prometheus datasource
- `common.datasources.loki` - Loki datasource

#### Dashboard helpers
- `common.defaultDashboard(title, tags, uid)` - Базовый dashboard с стандартными настройками

#### Panel helpers
- `common.defaultTimeseries(title, datasource)` - Timeseries панель
- `common.defaultGauge(title, datasource)` - Gauge панель
- `common.defaultLogs(title, datasource)` - Logs панель
- `common.defaultStat(title, datasource)` - Stat панель

#### Query helpers
- `common.prometheusQuery(expr, legendFormat, refId)` - Prometheus query
- `common.lokiQuery(expr, legendFormat, refId)` - Loki query

#### Thresholds
- `common.thresholds.cpu` - CPU пороги (70% yellow, 90% red)
- `common.thresholds.memory` - Memory пороги (75% yellow, 90% red)

### Создание переиспользуемых компонентов

В `lib/common.libsonnet` можно добавлять свои функции:

```jsonnet
// Пример: функция для создания CPU gauge
cpuGauge(title, expr)::
  self.defaultGauge(title, self.datasources.prometheus)
  + g.panel.gauge.queryOptions.withTargets([
    self.prometheusQuery(expr, 'CPU Usage'),
  ])
  + g.panel.gauge.standardOptions.withUnit('percent')
  + g.panel.gauge.standardOptions.thresholds.withSteps(self.thresholds.cpu.steps),
```

### Параметризация дашбордов

Создайте функцию для генерации похожих дашбордов:

```jsonnet
local createServiceDashboard(serviceName) =
  common.defaultDashboard(
    '%s - Metrics' % serviceName,
    tags=[serviceName],
    uid='%s-metrics' % serviceName
  )
  + g.dashboard.withPanels([
    // ... панели с фильтром job=serviceName
  ]);

// Создать дашборды для нескольких сервисов
createServiceDashboard('service-a')
```

## Workflow

### Локальная разработка

1. Редактируй `.jsonnet` файлы в `dashboards-jsonnet/`
2. Запусти `make dashboards` для генерации JSON
3. Grafana автоматически подхватит изменения (provisioning настроен)
4. Коммить нужно только `.jsonnet` источники (JSON генерируется в CI/CD)

### CI/CD Pipeline

При push в master:
1. GitHub Actions запускает Docker build
2. Docker multi-stage build:
   - Stage 1: Устанавливает jsonnet/jb и собирает дашборды
   - Stage 2: Копирует сгенерированные JSON в финальный образ
3. Образ пушится в GHCR
4. VPS скачивает образ и разворачивает конфиги

**Важно:** Не нужно коммитить сгенерированные JSON файлы - они собираются автоматически в Docker!

## Tips

- Используй `make validate` перед коммитом
- Используй `make watch` при активной разработке
- Создавай функции в `lib/common.libsonnet` для повторяющихся паттернов
- Документируй сложные функции комментариями
- Смотри [официальную документацию Grafonnet](https://grafana.github.io/grafonnet/)

## Troubleshooting

### `jsonnet: command not found`
Установи jsonnet: `brew install jsonnet`

### `jb: command not found`
Установи jsonnet-bundler: `brew install jsonnet-bundler`

### Ошибка импорта grafonnet
Запусти `jb install` для установки зависимостей

### Дашборд не обновляется в Grafana
1. Проверь что запустил `make dashboards`
2. Проверь что JSON файл обновился в `config/grafana/dashboards/`
3. Grafana provisioning обновляется каждые 10 секунд (см. `dashboards.yml`)
