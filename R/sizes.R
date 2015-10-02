#' Get all the available sizes that can be used to create a droplet.
#'
#' @export
#' @inheritParams droplets
#' @return A data.frame with available sizes (RAM, disk, no. CPU's) and their costs
#' @param ... Named options passed on to \code{\link[httr]{GET}}.
#' @examples \dontrun{
#' sizes()
#' }
sizes <- function(page = 1, per_page = 25, ...) {
  res <- do_GET('sizes', query = list(page = page, per_page = per_page), ...)
  sizes <- res$sizes

  data.frame(
    slug = pluck(sizes, "slug", character(1)),
    memory = pluck(sizes, "memory", numeric(1)),
    vcpus = pluck(sizes, "vcpus", numeric(1)),
    disk = pluck(sizes, "disk", numeric(1)),
    transfer = pluck(sizes, "transfer", numeric(1)),
    price_monthly = pluck(sizes, "price_monthly", numeric(1)),
    price_hourly = pluck(sizes, "price_hourly", numeric(1)),
    available = pluck(sizes, "available", logical(1)),
    region = vapply(sizes, function(x) paste0(sort(unlist(x$regions)), collapse = ", "),
      character(1)),
    stringsAsFactors = FALSE
  )

}
