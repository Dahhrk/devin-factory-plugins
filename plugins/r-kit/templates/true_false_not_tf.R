# Prefer TRUE/FALSE over reassignable T/F symbols.
flag_enabled <- function(flag = TRUE) {
  if (isTRUE(flag)) {
    return(TRUE)
  }
  FALSE
}
