"""Compare the existing local Codex website with the Hermes WebUI smoke prompt."""

import json
import time
import urllib.request
from pathlib import Path


BASE = "http://127.0.0.1:8765"
ROOT = Path(__file__).resolve().parent.parent


def call(path, token=None, data=None):
    headers = {}
    if token:
        headers["Authorization"] = "Bearer " + token
    if data is not None:
        data = json.dumps(data).encode()
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(BASE + path, data=data, headers=headers)
    with urllib.request.urlopen(request, timeout=15) as response:
        return json.load(response)


password = (ROOT / "runtime/web_admin_password.txt").read_text(encoding="utf-8").strip()
token = call("/api/login", data={"password": password})["token"]
chat = call("/api/chats", token, {})
started = time.perf_counter()
job_id = call(
    f"/api/chats/{chat['id']}/messages", token,
    {"text": "Ответь одним словом: РАБОТАЕТ", "mode": "fast"},
)["job_id"]
for _ in range(240):
    time.sleep(0.5)
    status = call(f"/api/jobs/{job_id}", token)
    if status["status"] != "running":
        break
else:
    raise RuntimeError("Codex website timed out")
elapsed = time.perf_counter() - started
if status["status"] != "done":
    raise RuntimeError(str(status))
messages = call(f"/api/chats/{chat['id']}", token)["messages"]
if "РАБОТАЕТ" not in messages[-1]["text"]:
    raise RuntimeError(f"Unexpected answer: {messages[-1]['text']}")
print(f"PASS: Existing Codex website returned expected answer in {elapsed:.1f}s")
