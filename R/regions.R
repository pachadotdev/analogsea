#' Get list of regions and their metadata
#' 
#' @export
#' @template params
#' @examples \dontrun{
#' regions()
#' regions(per_page=2)
#' regions('raw')
#' }
regions <- function(page=1, per_page=25, ...) {
  do_GET('regions', query = list(page = page, per_page  =per_page), ...)
}
