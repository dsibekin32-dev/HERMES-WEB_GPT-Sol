"""Local end-to-end Hermes WebUI check using an isolated test session."""

import json
import time
import urllib.request
from http.cookiejar import CookieJar
from pathlib import Path


ROOT = Path(__file__).resolve().parent
BASE = "http://127.0.0.1:8787"
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(CookieJar()))


def post(path: str, data: dict) -> dict:
    request = urllib.request.Request(
        BASE + path,
        data=json.dumps(data).encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    with opener.open(request, timeout=180) as response:
        return json.load(response)


password = (ROOT / "state/webui_password.txt").read_text(encoding="utf-8").strip()
assert post("/api/auth/login", {"password": password}).get("ok")
session = post("/api/session/new", {
    "workspace": str(ROOT / "workspace"),
    "model": "gpt-6-sol",
    "model_provider": "openai-codex",
    "worktree": False,
})["session"]
started = time.perf_counter()
reply = post("/api/chat", {
    "session_id": session["session_id"],
    "message": "Ответь одним словом: РАБОТАЕТ",
})
elapsed = time.perf_counter() - started
if reply.get("status") != "done" or "РАБОТАЕТ" not in reply.get("answer", ""):
    raise RuntimeError(f"Unexpected Hermes reply: {reply.get('status')}: {reply.get('answer')}")
print(f"PASS: Hermes WebUI returned expected answer in {elapsed:.1f}s")
