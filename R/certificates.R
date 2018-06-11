certificate_url <- function(certificate = NULL) {
  url("certificates", certificate)
}

#' @param x Object to coerce to an certificate
#' @export
#' @rdname certificates
as.certificate <- function(x) UseMethod("as.certificate")
#' @export
as.certificate.list <- function(x) list_to_object(x, "certificate")
#' @export
as.certificate.certificate <- function(x) x
#' @export
as.certificate.character <- function(x) certificate(x)

#' Get list of certificate and their metadata, or a single certificate
#'
#' @export
#' @param id (numeric) certificate id
#' @param name (character) a certificate name
#' @param type (character) a string representing the type of certificate. 
#' The value should be "custom" for a user-uploaded certificate or 
#' "lets_encrypt" for one automatically generated with Let's Encrypt. 
#' If not provided, "custom" will be assumed by default.
#' @param private_key (character) the contents of a PEM-formatted private-key 
#' corresponding to the SSL certificate
#' @param leaf_certificate (character) the contents of a PEM-formatted public 
#' SSL certificate
#' @param certificate_chain (character) the full PEM-formatted trust chain 
#' between the certificate authority's certificate and your domain's 
#' SSL certificate
#' @param dns_names (character) a vector of fully qualified domain names 
#' (FQDNs) for which the certificate will be issued. The domains must be 
#' managed using DigitalOcean's DNS
#' @inheritParams droplets
#' @examples \dontrun{
#' # list certificates
#' certificates()
#' 
#' # create a certificate (create a fake domain first)
#' d <- domain_create('tablesandchairsbunnies.stuff', '107.170.220.59')
#' certificate_create("mycert", "lets_encrypt", 
#'   dns_names = list('tablesandchairsbunnies.stuff'))
#' }
certificates <- function(page = 1, per_page = 25, ...) {
  res <- do_GET(certificate_url(),
                query = list(page = page, per_page = per_page), ...)
  as.certificate(res)
}

#' @export
#' @rdname certificates
certificate <- function(id, ...) {
  res <- do_GET(certificate_url(id), ...)
  as.certificate(res)
}

#' @export
#' @rdname certificates
certificate_create <- function(name, type, private_key = NULL, 
  leaf_certificate = NULL, certificate_chain = NULL, 
  dns_names = NULL, ...) {

  body <- ascompact(
    list(name = name, type = type, private_key = private_key,
      leaf_certificate = leaf_certificate, 
      certificate_chain = certificate_chain, dns_names = dns_names))
  as.certificate(do_POST("certificates", ..., body = body))
}

#' @export
print.certificate <- function(x, ...) {
  cat("<certificate> ", x$name, " (", x$id, ")", "\n", sep = "")
  cat("  Status:    ", x$status, "\n", sep = "")
}

#' @export
as.url.certificate <- function(x, ...) {
  certificate_url(x$id)
}

#' Delete a certificate
#' @export
#' @param id A certificate id (not the name) to delete
#' @param ... Options passed on to httr::DELETE
certificate_delete <- function(id, ...) {
  id <- as.certificate(id)
  do_DELETE(file.path('certificates', id$id), ...)
}
