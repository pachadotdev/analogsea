do_base <- "https://api.digitalocean.com/v2"

url <- function(...) structure(paste(do_base, ..., sep = "/"), class = "do_url")
#' @export
print.do_url <- function(x, ...) {
  cat("<url> ", x, "\n", sep = "")
}

as.url <- function(x, ...) UseMethod("as.url")
#' @export
as.url.character <- function(x, ...) paste0(do_base, "/", x)
#' @export
as.url.do_url <- function(x, ...) x

#' httr wrappers.
#'
#' @keywords internal
#' @name httr-verbs
NULL

#' @export
#' @rdname httr-verbs
do_GET <- function(url, ...) {
  do_VERB("GET", url, ...)
}
#' @export
#' @rdname httr-verbs
do_POST <- function(url, ..., body = NULL, encode = "json") {
  body <- ascompact(body)
  do_VERB("POST", url, ..., body = body, encode = encode)
}
#' @export
#' @rdname httr-verbs
do_PUT <- function(url, ...) {
  do_VERB("PUT", url, ...)
}
#' @export
#' @rdname httr-verbs
do_DELETE <- function(url, ...) {
  do_VERB("DELETE", url, ...)
}

do_VERB <- function(verb, url, ...) {
  url <- as.url(url)
  VERB <- getExportedValue("httr", verb)

  res <- VERB(url, ..., do_oauth())
  # No content
  if (length(res$content) == 0) {
    httr::stop_for_status(res)
    return(invisible(TRUE))
  }

  text <- httr::content(res, as = "text")
  json <- jsonlite::fromJSON(text, simplifyVector = FALSE)

  if (httr::status_code(res) >= 400) {
    stop(json$message, call. = FALSE)
  }

  json
}
