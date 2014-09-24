#' List all available droplets.
#'
#' @export
#' @param ... Additional arguments passed down to low-level API function 
#'   (\code{do_*})
#' @param page Page to return
#' @param per_page Number of results per page
#' @param config Additional httr config options.
#' @examples \dontrun{
#' droplets()
#' }
droplets <- function(...) {
  res <- do_droplets(...)
  droplets <- lapply(res$droplets, structure, class = "droplet")
  names(droplets) <- vapply(res$droplets, function(x) x$name, character(1))
  droplets
}

#' @export
#' @rdname droplets
do_droplets <- function(page = 1, per_page = 25, config = NULL) {
  do_GET("parsed", "droplets", 
    query = list(page = page, per_page = per_page), 
    config = config, parse = FALSE
  )
}
