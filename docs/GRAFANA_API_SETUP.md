# Grafana API Key для Annotations

## Зачем нужно

Annotations - вертикальные маркеры на графиках с информацией о деплоях:

```
CPU Usage
  80% |         📍 ← Деплой в 10:30
      |        /|
  60% |   ____/ |\___ После деплоя CPU вырос!
```

Позволяет быстро найти причину проблем на графиках.

---

## Создание API Key

### После первого деплоя:

1. **Открой Grafana**: https://proflyder.dev/grafana/
2. **Administration** → **Service accounts**
3. **Add service account**:
   - Display name: `GitHub Actions Deploy`
   - Role: `Editor`
4. **Create**
5. **Add service account token**:
   - Display name: `deploy-annotations`
   - Expiration: `No expiration`
6. **Generate token**
7. **Скопируй токен** (показывается один раз!)

### Добавь в GitHub Secrets:

- Name: `GRAFANA_API_KEY`
- Value: `eyJrIjoiXXXXXXXXX...`

---

## Проверка работы

После следующего деплоя на всех дашбордах появятся маркеры:

**При успехе:**
```
✅ Deployment successful
Commit: abc123
By: username
Tags: deployment, production, success
```

**При rollback:**
```
⚠️ Deployment failed - Rollback executed
Commit: abc123
Tags: deployment, rollback, failure
```

---

## Troubleshooting

### 401 Unauthorized
Неверный API key. Создай новый и обнови secret в GitHub.

### 403 Forbidden
API key должен иметь роль `Editor` (не `Viewer`).

### Аннотации не видны
Dashboard → Settings → Annotations → Убедись что "Show annotations" включено.

---

## Если не настроишь

Деплой будет работать нормально, просто без маркеров на графиках. Это опционально.
