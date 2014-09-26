#' Get all the available sizes that can be used to create a droplet.
#'
#' @export
#' @template params
#' @return A data.frame with available sizes (RAM, disk, no. CPU's) and their costs
#' @examples \dontrun{
#' sizes()
#' sizes(per_page=2)
#' res <- sizes('raw')
#' res$url
#' res$headers
#' }

sizes <- function(page=1, per_page=25) {
  do_GET('sizes', query = list(page = page, per_page = per_page))
}
