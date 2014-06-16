#' Get request and output result or errors
#'
#' @import httr jsonlite assertthat XML
#' @export
#' @param what What to return, parsed or raw
#' @param droplets (logical) If TRUE, selects droplets element and returns that
#' @param path Path to append to the end of the base Digital Ocean API URL
#' @param query Arguments to GET
#' @param ... Options passed on to httr::GET. Must be named, see examples.
#' @return Some combination of warnings and httr response object or list

do_GET <- function(what, droplets=FALSE, path, query = NULL, ...) {
  url <- file.path("https://api.digitalocean.com/v2", path)
  au <- do_get_auth()
  args <- c(list(client_id = au$id, api_key = au$key), query)

  tt <- GET(url, query = args, ...)
  if(tt$status_code > 202 || content(tt)$status == "ERROR"){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  if(what=='parsed'){
    tmp <- fromJSON(res, FALSE)
    if(droplets) tmp[ !names(tmp) %in% 'status' ] else tmp
  } else { tt }
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
  tmp <- Sys.which(c("ssh","scp"))
  nf <- names(tmp[vapply(tmp, nchar, 1) == 0])
  if(length(nf) != 0)
    stop(sprintf("%s not found on your computer\nTry ssh'ing into the machine\n    (ssh root@%s)\n& manually installing things. See ?do_scripts for help", nf, ip))
}

check_droplet <- function(x){
  if(class(x) == "response"){
    message("httr response object detected, passing")
    NULL
  } else {
    if(!is.null(x)){
      if(is.list(x)){
        if(length(x$droplet_ids) > 1) message("More than 1 droplet, using first")
        x <- x$droplet_ids[[1]]
        if(!is.numeric(x)) stop("Could not detect a droplet id")
      } else {
        x <- as.numeric(as.character(x))
        if(!is.numeric(x)) stop("Could not detect a droplet id")
      }
      x 
    } else { NULL }
  }
}

match_droplet <- function(x){
  if(length(x$droplet_ids) > 1){
    x[vapply(x, "[[", 1, "id")==id]
  } else { x }
}