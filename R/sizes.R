#' Get all the available sizes that can be used to create a droplet.
#'
#' @export
#' @template pages
#' @return A data.frame with available sizes (RAM, disk, no. CPU's) and their costs
#' @param ... Options passed on to httr::GET. Must be named, see examples.
#' @examples \dontrun{
#' sizes()
#' sizes(per_page=2)
#' res$url
#' res$headers
#' }

sizes <- function(page=1, per_page=25, ...) {
  do_GET('sizes', query = list(page = page, per_page = per_page))
}
