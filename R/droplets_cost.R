#' Calculate cost across droplets
#'
#' @export
#' @param x Object to coerce. Can be an integer (droplet id), string
#' (droplet name), a droplet (duh)
#' @examples \dontrun{
#' droplets() %>% droplets_cost()
#' droplets()[[2]] %>% droplets_cost()
#' droplets()[2:4] %>% droplets_cost()
#' droplets_cost("FatedSpaghetti")
#' droplets_cost(11877599)
#' }
droplets_cost <- function(x) {
  if (!inherits(x, "list")) {
    if (inherits(x, "character") || inherits(x, "numeric")) x <- as.droplet(x)
    x <- setNames(list(x), x$name)
  }
  x <- ascompact(lapply(x, as.droplet))
  res <- as.list(vapply(x, function(z) {
    price <- z$size$price_hourly
    crat <- as.POSIXct(strptime(z$created_at, "%Y-%m-%dT%H:%M:%S", "UTC"))
    now <- as.POSIXlt(Sys.time(), "UTC")
    round(difftime(now, crat, units = "hours")[[1]] * price, 3)
  }, numeric(1)))
  if (length(res) > 0) {
    res <- c(res, total = sum(unlist(res)))
  }
  res
}
