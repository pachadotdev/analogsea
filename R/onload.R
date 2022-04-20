analogsea_sessions <- NULL

.onLoad <- function(libname, pkgname) {
  analogsea_sessions <<- new.env()

  op <- options()
  op.do <- list(
    do.wait_time = 1
  )
  toset <- !(names(op.do) %in% names(op))
  if (any(toset)) options(op.do[toset])
  invisible()
}
