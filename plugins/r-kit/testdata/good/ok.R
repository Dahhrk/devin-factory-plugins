summarise_cars <- function(data = datasets::mtcars, verbose = TRUE) {
  if (isTRUE(verbose)) {
    message("n=", nrow(data))
  }
  mean(data$mpg, na.rm = TRUE)
}

# Documented intentional seam; keep allow on the smell line.
attach(list(x = 1)) # r-rg-allow: fixture documents allow marker for intentional attach seam
