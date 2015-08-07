#' Get account information
#'
#' @export
#' @param ... Options passed down to \code{\link[httr]{GET}}
#' @inheritParams droplets
#' @examples \dontrun{
#' account()
#' }
account <- function(...) structure(do_GET("account", list(), ...), class = "account")

#' @export
print.account <- function(x, ...) {
  cat("<account> ", sep = "\n")
  cat("  E-mail:          ", x$account$email, "\n")
  cat("  E-mail verified: ", x$account$email_verified, "\n")
  cat("  UUID:            ", x$account$uuid, "\n")
  cat("  Droplet limit:   ", x$account$droplet_limit, "\n")
  cat("  Status:          ", x$account$status, "\n")
  cat("  Status message:  ", x$account$status_message)
}
