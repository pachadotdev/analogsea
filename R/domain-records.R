domain_record_url <- function(domain, record = NULL) {
  url("domains", domain, "records", record)
}

#' @export
#' @rdname domain_records
as.domain_record <- function(x, domain) UseMethod("as.domain_record")
#' @export
#' @rdname domain_records
as.domain_record.list <- function(x, domain) {
  x <- list_to_object(x, "domain_record", name = NULL)
  if (inherits(x, "domain_record")) {
    x$domain <- domain
    x
  } else {
    lapply(x, function(y) {
      y$domain <- domain
      y
    })
  }
}
#' @export
#' @rdname domain_records
as.domain_record.domain_record <- function(x, domain) x

#' @export
print.domain_record <- function(x, ...) {
  cat("<domain_record> ", x$id, "\n", sep = "")
  cat("  ", x$type, " ", x$data, "\n", sep = "")
}

#' @export
#' @rdname domain_records
as.url.domain_record <- function(x, ...) {
  domain_record_url(x$domain$name, x$id)
}

#' List, create and delete domain records.
#'
#' @export
#' @param domain (domain) Required. Domain Name (e.g. domain.com), specifies 
#'   the domain for which to create a record.
#' @param type (character) Required. The type of record you would like to 
#'   create. 'A', 'CNAME', 'NS', 'TXT', 'MX' or 'SRV'
#' @param name (character) The host name, alias, or service being defined by 
#'   the record. Required for 'A', 'CNAME', 'TXT' and 'SRV' records
#' @param data (character) Variable data depending on record type. Required 
#'   for 'A', 'AAAA', 'CNAME', 'MX', 'TXT', 'SRV', and 'NS' records
#' @param priority (integer) Required for 'SRV' and 'MX' records
#' @param port (integer) Required for 'SRV' records
#' @param weight (integer) Required for 'SRV' records
#' @param domain_record A domain record.
#' @param x Domain record.
#' @param ... Further args passed on the curl call to the web.
#' @examples \dontrun{
#' d <- domains()[[1]]
#' domain_records(d)
#' 
#' dr <- domain_record_create(d, "TXT", data = "Hi Mom!")
#' domain_records(d)
#' domain_record_delete(dr)
#' }
domain_records <- function(domain, ...) {
  domain <- as.domain(domain)
  as.domain_record(do_GET(domain_record_url(domain$name)), domain)
}

#' @export
#' @rdname domain_records
domain_record_create <- function(domain, type, name = NULL, data = NULL, 
                                  priority = NULL, port = NULL, weight = NULL,
                                  ...) {
  domain <- as.domain(domain)
  
  res <- do_POST(domain_record_url(domain$name),
    body = list(type = type, data = data, name = name, priority = priority, 
      port = port, weight = weight),
    encode="multipart",
    ...)
  as.domain_record(res, domain = domain)
}

#' @export
#' @rdname domain_records
domain_record_delete <- function(domain_record, ...) {
  domain_record <- as.domain_record(domain_record)
  do_DELETE(domain_record, ...)
}
