from mako.lookup import TemplateLookup

lookup = TemplateLookup(
    directories=["templates"],
    input_encoding="utf-8",
    default_filters=["str", "h"],
    module_directory="/var/cache/mako_modules",  # mako-rg-allow: fixture documents allow marker for intentional locked module_directory path seam
)
