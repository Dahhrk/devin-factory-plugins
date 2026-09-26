"""Named JSON / wire parse boundary template.

Move bare json.loads behind a function; mark the parse line with py-rg-allow.
"""

from __future__ import annotations

import json
from typing import Any


def parse_json_unknown(text: str) -> Any:
    return json.loads(text)  # py-rg-allow named JSON boundary


def parse_json_object(text: str) -> dict[str, Any]:
    value = parse_json_unknown(text)
    if not isinstance(value, dict):
        raise TypeError("expected JSON object")
    return value
