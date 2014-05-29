#' Get request and output result or errors
#'
#' @import httr jsonlite assertthat XML
#' @export
#' @param what What to return, parsed or raw
#' @param path Path to append to the end of the base Digital Ocean API URL
#' @param query Arguments to GET
#' @param ... Options passed on to httr::GET. Must be named, see examples.
#' @return Some combination of warnings and httr response object or list

do_handle <- function(what, path, query = NULL, ...) {
  url <- file.path("https://api.digitalocean.com/v1", path)
  au <- do_get_auth()
  args <- c(list(client_id = au$id, api_key = au$key), query)

  tt <- GET(url, query = args, ...)
  if(tt$status_code > 202 || content(tt)$status == "ERROR"){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  if(what=='parsed') fromJSON(res, FALSE) else tt
}

#' Compact
#'
#' @param ... List input
#' @keywords internal
ct <- function (...) Filter(Negate(is.null), list(...))

mssg <- function(x, y) if(x) message(y)

writefile <- function(filename, installstring){
  installrfile = filename
  fileConn <- file(installrfile)
  writeLines(installstring, fileConn)
  close(fileConn)
}

cli_tools <- function(ip){
  tmp <- Sys.which(c("ssh","scpasdf"))
  nf <- names(tmp[vapply(tmp, nchar, 1) == 0])
  if(length(nf) != 0)
    stop(sprintf("%s not found on your computer\nTry ssh'ing into the machine\n    (ssh root@%s)\n& manually installing things. See ?do_scripts for help", nf, ip))
}