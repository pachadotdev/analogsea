#' Get number of Objects in a Space
#' @param space A Space, or something that can be coerced to a Space by
#'   \code{\link{as.space}}.
#' @return (numeric) The number of files in the Space.
#' @export
space_files <- function(space) {
  space <- as.space(space)
  space_info <- space_info(space)

  # remove entries with size 0 (those are nested directories)
  length(lapply(space_info, function(x) x[x$Size > 0]))
}
