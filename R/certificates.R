certificate_url <- function(certificate = NULL) {
  url("certificates", certificate)
}

#' @param x Object to coerce to an certificate
#' @export
#' @rdname firewalls
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
#' @param id (numeric) certificate id.
#' @param name (character) a certificate name
#' @param inbound_rules (list) inbound rules
#' @param outbound_rules (list) outbound rules
#' @param droplet_ids (numeric/integer) droplet ids
#' @param tags (character) tag strings
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
#' @rdname firewalls
certificate <- function(id, ...) {
  res <- do_GET(certificate_url(id), ...)
  as.certificate(res)
}

#' @export
#' @rdname firewalls
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
