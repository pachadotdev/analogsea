#' List all available droplets.
#'
#' @export
#' @param ... Additional arguments passed down to low-level API function
#'   (\code{do_*})
#' @param tag (character) Name of a tag. optional
#' @param page Page to return. Default: 1.
#' @param per_page Number of results per page. Default: 25.
#' @examples \dontrun{
#' droplets()
#' droplets(per_page = 2)
#' droplets(per_page = 2, page = 2)
#'
#' # list droplets by tag
#' tag_create(name = "stuffthings")
#' d <- droplet_create()
#' tag_resource(name = "stuffthings", resource_id = d$id, resource_type = "droplet")
#' droplets(tag = "stuffthings")
#' }
droplets <- function(..., page = 1, per_page = 25, tag = NULL) {
  res <- do_GET("droplets", query = list(page = page, per_page = per_page, tag_name = tag), ...)
  droplets <- lapply(res$droplets, structure, class = "droplet")
  setNames(droplets, vapply(res$droplets, function(x) x$name, character(1)))
}
