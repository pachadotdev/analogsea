#' Get information on a single domain or all your domains.
#'
#' @export
#' @param domain (character) Required. Domain name
#' @template params
#' @examples \dontrun{
#' domains()
#' }
domains <- function(...) {
  as.domain(do_GET("parsed", domain_url(), ...))
}

#' @rdname domains
#' @export
as.domain <- function(x) UseMethod("as.domain")
#' @export
as.domain.character <- function(x) domain(x)
#' @export
as.domain.list <- function(x) list_to_object(x, "domain")
#' @export
as.domain.domain <- function(x) x

#' @rdname domains
#' @export
domain <- function(x, ...) {
  as.domain(do_GET("parsed", domain_url(x), ...))
}

#' @export
as.url.domain <- function(x) domain_url(x$name)
domain_url <- function(x = NULL) url("domains", x)

#' @export
print.domain <- function(x, ...) {
  cat("<domain> ", x$name, "\n", sep = "")
  cat("  ttl: ", x$ttl, "\n", sep = "")
}

#' Create/delete domains.
#'
#' @export
#' @param domain A domain to modify
#' @param name (character) Required. The domain name to add to the 
#'   DigitalOcean DNS management interface. The name must be unique in 
#'   DigitalOcean's DNS system. The request will fail if the name has already 
#'   been taken.
#' @param ip_address (character) Required. An IP address for the domain's 
#'   initial A record.
#' @examples \dontrun{
#' d <- domain_create('tablesandchairsbunnies.info', '107.170.220.59')
#' domain_delete(d)
#' }
domain_create <- function(name, ip_address, ...) {
  as.domain(do_POST("parsed", domain_url(), 
    args = list(name = name, ip_address = ip_address), 
    ...
  ))
}

#' @rdname domain_create
#' @export
domain_delete <- function(domain, ...) {
  domain <- as.domain(domain)
  do_DELETE(domain)
}
