from ok import ok, parse_json_object


def test_ok_returns_list() -> None:
    assert isinstance(ok(), list)


def test_parse_json_object() -> None:
    assert parse_json_object('{"a": 1}')["a"] == 1
