# Named boundary: prefer TemplateLookup without module_directory code-exec cache.
# Anti-pattern (banned without allow): module_directory="/tmp/mako_modules"
# Anti-pattern (banned without allow): disable_unicode=True / input_encoding=None

from mako.lookup import TemplateLookup

lookup = TemplateLookup(
    directories=["templates"],
    input_encoding="utf-8",
    default_filters=["str", "h"],
)
