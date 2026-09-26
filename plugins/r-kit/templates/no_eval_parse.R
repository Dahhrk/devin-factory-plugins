# Prefer get / [[ / explicit maps over eval(parse()).
lookup_handler <- function(name, handlers) {
  stopifnot(is.character(name), length(name) == 1L)
  if (!name %in% names(handlers)) {
    stop(sprintf("unknown handler: %s", name), call. = FALSE)
  }
  handlers[[name]]
}

run_named <- function(name, handlers, ...) {
  fn <- lookup_handler(name, handlers)
  fn(...)
}

# Dynamic symbol fetch without parse/eval:
read_binding <- function(name, envir = parent.frame()) {
  get(name, envir = envir, inherits = TRUE)
}
