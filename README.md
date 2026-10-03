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

Для остановки видимого запуска нажмите Ctrl+C. Фоновый экземпляр можно остановить командой `powershell -ExecutionPolicy Bypass -File .\stop-hermes-webui.ps1`. Hermes использует отдельный вход в подписку OpenAI. Если Hermes сообщает, что входа нет, выполните в этой папке:

```powershell
$env:HERMES_HOME = (Join-Path (Get-Location) 'state')
.\venv\Scripts\hermes.exe auth add openai-codex --type oauth --browser
```

Затем подтвердите вход в открывшемся окне браузера. Hermes ждёт обратный вызов на `http://localhost:1455/auth/callback`. Пароли и OAuth-токены в команду вставлять не нужно. Исходный сайт Codex на порту 8765 остаётся независимым.

## Проверка

`venv\Scripts\python.exe smoke_hermes_webui.py` проверяет вход, создание чата и реальный ответ Codex через Hermes WebUI. `venv\Scripts\python.exe benchmark_current_web.py` проверяет прежний сайт на том же коротком запросе. Время ответа зависит от загрузки модели и длины задачи; одна пара запусков не доказывает постоянное преимущество какого-либо варианта.

## Состав репозитория

| Файл | Назначение |
| --- | --- |
| `start-hermes-webui.ps1` | Задаёт локальные пути и пароль, запускает WebUI на порту 8787. |
| `stop-hermes-webui.ps1` | Останавливает локальный сервер этой обвязки. |
| `ensure-hermes-webui.ps1` | Проверяет сервер и запускает его в скрытом окне, если он не отвечает. |
| `register-hermes-autostart.ps1` | Создаёт задачу Windows для запуска при входе пользователя. |
| `smoke_hermes_webui.py` | Проверяет вход, создание чата и ответ модели. |
| `benchmark_current_web.py` | Отправляет тот же запрос в отдельный сайт Codex на порту 8765. |
| `check-tailscale.ps1` | Сохраняет состояние Tailscale и Funnel в `state`. |
| `enable-hermes-funnel.ps1` | Включает публичный доступ к порту 8787 через Tailscale Funnel. |

Скрипты ожидают такую структуру:

```text
hermes-prototype/
├── hermes-agent-main/       # исходники Hermes Agent; не входят в Git
├── hermes-webui-master/     # исходники Hermes WebUI; не входят в Git
├── venv/                    # виртуальное окружение Python; не входит в Git
├── state/                   # пароль, токены, чаты, настройки; не входит в Git
├── workspace/               # рабочие файлы агента; не входят в Git
├── tmp/                     # временные файлы; не входят в Git
└── *.ps1, *.py, README.md  # файлы этого репозитория
```

Папки `state`, `workspace`, `venv`, `tmp`, обе папки с исходниками и ZIP-архивы исключены в `.gitignore`. После клонирования этого репозитория их потребуется создать заново. Никакие пароли или OAuth-токены из Git не восстанавливаются.

## Установка на другом компьютере

Нужны Windows, PowerShell, Git и Python 3.11–3.14. Локальная сборка, для которой сделана эта обвязка, работает на Python 3.14.3. Из каталога `hermes-prototype` выполните:

```powershell
git clone https://github.com/NousResearch/hermes-agent.git hermes-agent-main
git clone https://github.com/nesquena/hermes-webui.git hermes-webui-master
python -m venv venv
.\venv\Scripts\python.exe -m pip install -e .\hermes-agent-main
.\venv\Scripts\python.exe -m pip install -r .\hermes-webui-master\requirements.txt
New-Item -ItemType Directory -Force state, workspace, tmp | Out-Null
```

Если исходники уже есть, не клонируйте поверх них. В этом репозитории не закреплены версии внешних проектов, поэтому новые версии могут потребовать других зависимостей или настроек. Для них читайте инструкции [Hermes Agent](https://github.com/NousResearch/hermes-agent) и [Hermes WebUI](https://github.com/nesquena/hermes-webui).

Создайте пароль WebUI. Команда выведет случайный пароль один раз и сохранит его в `state/webui_password.txt`; перенесите его в менеджер паролей:

```powershell
.\venv\Scripts\python.exe -c "import pathlib,secrets; p=pathlib.Path('state/webui_password.txt'); s=secrets.token_urlsafe(32); p.write_text(s,encoding='utf-8'); print(s)"
```

Затем выполните OAuth-вход из раздела «Запуск» и запустите WebUI. Пароль WebUI и вход Hermes — разные вещи: первый защищает веб-интерфейс, второй даёт Hermes доступ к модели. Прежний сайт Codex на порту 8765 имеет собственные пароль и вход.

## Как работают скрипты

`start-hermes-webui.ps1` выставляет `HERMES_HOME=state`, папку состояния WebUI, путь к исходникам Hermes Agent, Python из `venv`, рабочую папку `workspace` и адрес `127.0.0.1:8787`. Он читает пароль из `state/webui_password.txt`, задаёт `HERMES_WEBUI_PASSWORD` и запускает `hermes-webui-master/server.py`. Оставьте окно PowerShell открытым либо используйте фоновый запуск.

`ensure-hermes-webui.ps1` обращается к `http://127.0.0.1:8787/api/auth/status` и, если сервер не отвечает, запускает основной скрипт в скрытом окне. `stop-hermes-webui.ps1` ищет процесс по локальному пути к `server.py` и останавливает его. Перед повторным запуском проверьте, что старый экземпляр остановлен.

Для автозапуска выполните:

```powershell
powershell -ExecutionPolicy Bypass -File .\register-hermes-autostart.ps1
```

Скрипт создаёт задачу Windows `HermesWebUI` для текущего пользователя и записывает её состояние в `state/autostart-status.txt`. Задачей можно управлять через «Планировщик заданий» Windows.

## Проверки

После запуска WebUI выполните:

```powershell
.\venv\Scripts\python.exe .\smoke_hermes_webui.py
```

Скрипт входит с локальным паролем, создаёт отдельный тестовый чат в `workspace` и просит модель `gpt-6-sol` через провайдера `openai-codex` ответить одним словом. Нужны действующий OAuth-вход, доступная модель и сетевое соединение. Тест расходует лимит подписки.

Если отдельно работает прежний сайт Codex на `127.0.0.1:8765`, выполните:

```powershell
.\venv\Scripts\python.exe .\benchmark_current_web.py
```

Этот скрипт читает пароль прежнего сайта из `../runtime/web_admin_password.txt`, создаёт чат и отправляет такой же запрос. На другом компьютере без прежнего сайта он не нужен.

## Tailscale и удалённый доступ

По умолчанию WebUI привязан к `127.0.0.1` и недоступен с другого устройства. `check-tailscale.ps1` сохраняет сведения о текущем Tailscale и Funnel в `state/tailscale-status.txt` и `state/tailscale-funnel.txt`.

`enable-hermes-funnel.ps1` выполняет `tailscale funnel --bg 8787`. **Funnel публикует WebUI в Интернете.** Включайте его только осознанно и с сильным паролем. Оба скрипта ожидают Tailscale по пути `C:\Program Files\Tailscale\tailscale.exe`; при другой установке измените `$cli`. Для доступа только из собственной сети Tailscale изучите Tailscale Serve вместо Funnel.

## Данные и безопасность

- Пароль WebUI: `state/webui_password.txt`.
- OAuth-токены, настройки, чаты и журналы Hermes: `state`.
- Рабочие файлы агента: `workspace`.
- Временные файлы: `tmp`.
- Скачанные исходники и зависимости: `hermes-agent-main`, `hermes-webui-master`, `venv`.

Не публикуйте содержимое этих папок и не прикладывайте их к GitHub issues. Приватный репозиторий не защитит секреты, если вручную добавить их в будущий коммит. Перед отправкой изменений проверяйте `git status` и `git diff --cached`.

## Если что-то не работает

| Симптом | Что проверить |
| --- | --- |
| Скрипт запуска не находит файл | Наличие `hermes-agent-main`, `hermes-webui-master/server.py`, `venv/Scripts/python.exe` и `state/webui_password.txt`. |
| WebUI не открывается | Запущен ли процесс и свободен ли порт 8787; открывайте `http://127.0.0.1:8787`. |
| Пароль не подходит | Содержимое `state/webui_password.txt` без пробелов; после замены пароля перезапустите сервер. |
| Нет входа в модель | Повторите OAuth-вход с `HERMES_HOME`, указывающим на эту папку `state`. |
| Проверка отвечает ошибкой модели | Доступность `gpt-6-sol` у вашего провайдера; тест закреплён за этой моделью. |
| Сервер запущен дважды | Остановите старый процесс `stop-hermes-webui.ps1`, затем запустите один экземпляр. |
| Не работает Funnel | Установлен ли Tailscale и разрешён ли Funnel для аккаунта; изучите файлы `state/tailscale-*.txt`. |
