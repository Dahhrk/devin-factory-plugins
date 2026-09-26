# Intentional smells for mako-rg-gate (not product).
from mako.lookup import TemplateLookup
from mako.template import Template

lookup = TemplateLookup(
    directories=["/tmp/tmpl"],
    module_directory="/tmp/mako_modules",
    disable_unicode=True,
    input_encoding=None,
    default_filters=[],
)

t = Template("x", module_directory="/var/tmp/mako_cache", disable_unicode=True)
