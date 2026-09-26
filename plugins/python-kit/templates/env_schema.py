"""Named env boundary template (copy into product src/env_schema.py or similar).

Prefer pydantic / attrs / dataclasses when the product already has one.
Whole-dict `os.environ` into the parser is the intended pattern; bare
`os.environ[KEY]` elsewhere still needs `py-rg-allow` on a named helper.
"""

from __future__ import annotations

import os
from typing import Mapping


class AppEnv(dict[str, str]):
    pass


def parse_env(raw: Mapping[str, str] | None = None) -> AppEnv:
    data = dict(raw) if raw is not None else dict(os.environ)  # py-rg-allow named env boundary
    node_env = data.get("NODE_ENV") or data.get("FLASK_ENV") or "development"
    if node_env not in {"development", "test", "production"}:
        raise ValueError("invalid NODE_ENV/FLASK_ENV")
    port_raw = data.get("PORT", "3000")
    try:
        port = int(port_raw)
    except ValueError as exc:
        raise ValueError("invalid PORT") from exc
    out = AppEnv(NODE_ENV=node_env, PORT=str(port))
    if database_url := data.get("DATABASE_URL"):
        out["DATABASE_URL"] = database_url
    return out


env = parse_env()
