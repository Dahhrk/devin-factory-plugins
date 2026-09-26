from __future__ import annotations

import json
import os
from typing import Any


def parse_env(raw: dict[str, str] | None = None) -> dict[str, str]:
    data = raw if raw is not None else dict(os.environ)
    return data


def parse_json_object(text: str) -> dict[str, Any]:
    value = json.loads(text)  # py-rg-allow named JSON boundary
    if not isinstance(value, dict):
        raise TypeError("expected JSON object")
    return value


def ok(items: list[str] | None = None) -> list[str]:
    buf = items if items is not None else []
    try:
        buf.append(parse_env().get("HOME", ""))
    except KeyError:
        pass
    return buf
