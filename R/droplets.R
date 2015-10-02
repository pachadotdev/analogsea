#' List all available droplets.
#'
#' @export
#' @param ... Additional arguments passed down to low-level API function
#'   (\code{do_*})
#' @param page Page to return. Default: 1.
#' @param per_page Number of results per page. Default: 25.
#' @examples \dontrun{
#' droplets()
#' }
droplets <- function(..., page = 1, per_page = 25) {
  res <- do_GET("droplets", query = list(page = page, per_page = per_page), ...)
  droplets <- lapply(res$droplets, structure, class = "droplet")
  setNames(droplets, vapply(res$droplets, function(x) x$name, character(1)))
}
