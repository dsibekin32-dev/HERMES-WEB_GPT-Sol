# Локальный прототип Hermes + Codex

Этот прототип изолирован от сайта на порту 8765. Hermes WebUI слушает только `127.0.0.1:8787`, поэтому сейчас доступен лишь на этом компьютере. Публичный доступ не включён.

Этот репозиторий содержит только локальные скрипты и инструкции. Исходный код Hermes Agent и Hermes WebUI, виртуальное окружение, рабочие файлы и `state` с паролями и OAuth-токенами не входят в Git. Скрипты ожидают исходные проекты в папках `hermes-agent-main` и `hermes-webui-master`. Их можно получить отдельно из [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) и [nesquena/hermes-webui](https://github.com/nesquena/hermes-webui).

## Что установлено

- Hermes Agent: исходный код в `hermes-agent-main`.
- Hermes WebUI: исходный код в `hermes-webui-master`.
- Python и зависимости: отдельное окружение `venv`.
- Настройки, пароль, чаты и журнал: `state`.
- Рабочие файлы агента: `workspace`.

Веб-пароль лежит в `state/webui_password.txt`; не публикуйте этот файл. Адрес сайта: <http://127.0.0.1:8787>.

## Запуск

В PowerShell из этой папки:

```powershell
powershell -ExecutionPolicy Bypass -File .\start-hermes-webui.ps1
```

Для остановки видимого запуска нажмите Ctrl+C. Фоновый экземпляр можно остановить командой `powershell -ExecutionPolicy Bypass -File .\stop-hermes-webui.ps1`. Прототип использует локальный Codex CLI и отдельный вход Hermes в подписку OpenAI. Если Hermes сообщает, что входа нет, выполните в этой папке:

```powershell
$env:HERMES_HOME = (Join-Path (Get-Location) 'state')
.\venv\Scripts\hermes.exe auth add openai-codex --type oauth --browser
```

Затем подтвердите вход в открывшемся окне браузера. Hermes ждёт обратный вызов на `http://localhost:1455/auth/callback`. Пароли и OAuth-токены в команду вставлять не нужно. Исходный сайт Codex на порту 8765 остаётся независимым.

## Проверка

`venv\Scripts\python.exe smoke_hermes_webui.py` проверяет вход, создание чата и реальный ответ Codex через Hermes WebUI. `venv\Scripts\python.exe benchmark_current_web.py` проверяет прежний сайт на том же коротком запросе. Время ответа зависит от загрузки модели и длины задачи; одна пара запусков не доказывает постоянное преимущество какого-либо варианта.
