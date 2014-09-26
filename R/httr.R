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

#' GET request and output result or errors
#'
#' @import httr jsonlite assertthat XML
#' @export
#' @keywords internal
#' @param what What to return, parsed or raw
#' @param path Path to append to the end of the base Digital Ocean API URL
#' @param query Arguments to GET
#' @param parse To parse result to data.frame or to list
#' @param config Options passed on to httr::GET. Must be named, see examples.
#' @return Some combination of warnings and httr response object, data.frame, or list

# Need to move page=1, per_page=25,  in here
do_GET <- function(what, path, query = NULL, parse=FALSE, config=NULL) {
  url <- as.url(path)

  tt <- GET(url, query = query, config = c(do_oauth(), config))
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(content(tt)$message, call. = FALSE)
    if(content(tt)$status == "ERROR") stop(content(tt)$message, call. = FALSE)
  }
  if(what=='parsed'){
    res <- content(tt, as = "text")
    jsonlite::fromJSON(res, parse)
  } else { tt }
  #   auth <- add_headers(Authorization = sprintf('Bearer %s', au$token))
}

#' Digital Ocean POST request handler
#'
#' @export
#' @keywords internal
#' @param what What to return, parsed or raw
#' @param path Path to append to the end of the base Digital Ocean API URL
#' @param args Arguments to POST
#' @param parse To parse result to data.frame or to list
#' @param config Options passed on to httr::GET. Must be named, see examples.
#' @param encodejson (logical) Whether to set \code{encode='json'} in \code{httr::POST} call.
#' @return Some combination of warnings and httr response object, data.frame, or list

do_POST <- function(what, path, args, parse=FALSE, config = NULL, encodejson=FALSE) {
  url <- as.url(path)
  args <- compact(args)
  
  if(encodejson)
    tt <- POST(url, config = c(do_oauth(), config), body=args, encode="json")
  else
    tt <- POST(url, config = c(do_oauth(), config), body=args)
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(content(tt)$message, call. = FALSE)
    if(content(tt)$status == "ERROR") stop(content(tt)$message, call. = FALSE)
  }
  if(what=='parsed'){
    res <- content(tt, as = "text")
    jsonlite::fromJSON(res, parse)
  } else { tt }
}

#' Digital Ocean PUT request handler
#'
#' @export
#' @keywords internal
#' @param what What to return, parsed or raw
#' @param path Path to append to the end of the base Digital Ocean API URL
#' @param args Arguments to POST
#' @param parse To parse result to data.frame or to list
#' @param config Options passed on to httr::GET. Must be named, see examples.
#' @return Some combination of warnings and httr response object, data.frame, or list

do_PUT <- function(what, path, args, parse=FALSE, config=NULL) {
  url <- as.url(path)

  tt <- PUT(url, config = c(do_oauth(), config), body=args)
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(content(tt)$message)
    if(content(tt)$status == "ERROR") stop(content(tt)$message)
  }
  if(what=='parsed'){
    res <- content(tt, as = "text")
    jsonlite::fromJSON(res, parse)
  } else { tt }
}


#' Digital Ocean DELETE request handler
#'
#' @export
#' @keywords internal
#' @param path Path to append to the end of the base Digital Ocean API URL
#' @param config Options passed on to httr::GET. Must be named, see examples.
#' @return Some combination of warnings and httr response object, data.frame, or list

do_DELETE <- function(path, config = NULL) {
  url <- as.url(path)
  
  tt <- DELETE(url, config = c(do_oauth(), config))
  if(tt$status_code > 204){
    if(tt$status_code > 204) stop(content(tt)$message)
    if(content(tt)$status == "ERROR") stop(content(tt)$message)
  }
  
  invisible(TRUE)
}
