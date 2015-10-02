#' Get list of regions and their metadata
#'
#' @export
#' @inheritParams droplets
#' @param ... Named options passed on to \code{\link[httr]{GET}}.
#' @examples \dontrun{
#' regions()
#' }
regions <- function(page = 1, per_page = 25, ...) {
  res <- do_GET('regions', query = list(page = page, per_page = per_page), ...)
  regions <- res$regions

  data.frame(
    slug = pluck(regions, "slug", character(1)),
    name = pluck(regions, "name", character(1)),
    sizes = vapply(regions, function(x) paste0(x$sizes, collapse = ", "),
      character(1)),
    available = pluck(regions, "available", logical(1)),
    features = vapply(regions, function(x) paste0(x$features, collapse = ", "),
      character(1)),
    stringsAsFactors = FALSE
  )
}
