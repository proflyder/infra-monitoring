# Конфигурация Grafana

## Настройки

| Параметр | Значение |
|----------|----------|
| Организация | **Proflyder** |
| Timezone | **Asia/Almaty** (UTC+6) |
| Первый день недели | **Понедельник** |
| Язык | **Английский** |

Конфиг: `config/grafana/grafana.ini`

---

## Применение изменений

### Перезапуск
```bash
docker compose restart grafana
```

### Полный пересоздание
```bash
docker compose down grafana
docker compose up -d grafana
```

---

## Проверка

### Timezone
```bash
docker compose exec grafana date
# Должно показать Asia/Almaty время
```

### Организация
```bash
curl -u admin:PASSWORD https://proflyder.dev/grafana/api/org
# Output: {"id":1,"name":"Proflyder",...}
```

### Конфиг
```bash
docker compose exec grafana cat /etc/grafana/grafana.ini | grep "instance_name"
# Output: instance_name = Proflyder Monitoring
```

---

## Backup

```bash
docker run --rm \
  -v infra-monitoring_grafana-data:/source \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/grafana-$(date +%Y%m%d).tar.gz -C /source .
```

## Restore

```bash
docker compose down grafana
docker volume rm infra-monitoring_grafana-data
docker volume create infra-monitoring_grafana-data
docker run --rm \
  -v infra-monitoring_grafana-data:/target \
  -v $(pwd)/backups:/backup \
  alpine sh -c "cd /target && tar xzf /backup/grafana-YYYYMMDD.tar.gz"
docker compose up -d grafana
```

---

## Troubleshooting

### Неправильное время
```bash
docker compose restart grafana
# Очисти кэш браузера (Ctrl+Shift+R)
```

### Организация не "Proflyder"
```bash
curl -X PUT https://proflyder.dev/grafana/api/org \
  -u admin:PASSWORD \
  -H "Content-Type: application/json" \
  -d '{"name":"Proflyder"}'
```
