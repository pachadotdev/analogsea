.onLoad <- function(libname, pkgname) {
  op <- options()
  op.do <- list(
    do.wait_time = 1
  )
  toset <- !(names(op.do) %in% names(op))
  if (any(toset)) options(op.do[toset])

  utils::data("words")
  utils::data("adjectives")
  utils::data("nouns")

  invisible()
}
