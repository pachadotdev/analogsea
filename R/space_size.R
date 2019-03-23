#' Get the total size of all Objects in a Space
#'
#' @param space A Space, or something that can be coerced to a Space by
#'   \code{\link{as.space}}.
#' @return (numeric) The total of size of all Objects in the space in GiB.
#' @export
#' @examples
#' \dontrun{
#' # First, create a new Space
#' new_space <- space_create("new space name")
#'
#' # Should be zero
#' space_size(new_space)
#'
#' # Upload a file
#' spaces_object_put("somefile", new_space)
#'
#' # Should no longer be zero
#' space_size(new_space)
#' }
space_size <- function(space) {
  space <- as.space(space)
  space_info <- space_info(space)

  # grab the sizes from each file (unit is bytes)
  sizes <- vapply(space_info, function(x) x$Size, numeric(1))

  # compute total size (convert to gb)
  sum(sizes) * 1e-09
}
