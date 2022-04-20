#' Rate limit information for the authenticated user.
#'
#' @keywords internal
#' @export
#' @examples
#' \dontrun{
#' rate_limit()
#' }
rate_limit <- function() {
  res <- httr::HEAD("https://api.digitalocean.com/v2/sizes", do_oauth())
  headers <- httr::headers(res)

  structure(
    list(
      limit = as.integer(headers$`ratelimit-limit`),
      remaining = as.integer(headers$`ratelimit-remaining`),
      reset = as.POSIXct(as.integer(headers$`ratelimit-reset`),
        origin = "1970-01-01")
    ),
    class = "do_rate"
  )
}

#' @export
print.do_rate <- function(x, ...){
  cat("Rate limit: ", x$limit, '\n', sep = "")
  cat("Remaining:  ", x$remaining, '\n', sep = "")
  diff <- difftime(x$reset, Sys.time(), units = "secs")
  cat("Resets in:  ", time(diff), "\n", sep = "")
}

time <- function(x) {
  x <- as.integer(x)

  if (x > 3600) {
    paste0(x %/% 3600, " hours")
  } else if (x > 300) {
    paste0(x %/% 60, " minutes")
  } else if (x > 60) {
    paste0(round(x / 60, 1), " minutes")
  } else {
    paste0(x, "s")
  }
}
