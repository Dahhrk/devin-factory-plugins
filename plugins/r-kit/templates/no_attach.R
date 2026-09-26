# Prefer pkg::fun / @importFrom over attach().
summarise_cars <- function(data = datasets::mtcars) {
  mean_mpg <- mean(data$mpg, na.rm = TRUE)
  list(mean_mpg = mean_mpg, n = nrow(data))
}
