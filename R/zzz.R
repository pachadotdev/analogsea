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

do_GET <- function(what, path, query = NULL, parse=FALSE, config=NULL) {
  url <- file.path("https://api.digitalocean.com/v2", path)
  auth <- do_oauth()
  tt <- GET(url, query = query, config = c(token = auth, config))
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(content(tt)$message)
    if(content(tt)$status == "ERROR") stop(content(tt)$message)
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
#' @return Some combination of warnings and httr response object, data.frame, or list

do_POST <- function(what, path, args, parse=FALSE, config=config) {
  url <- file.path("https://api.digitalocean.com/v2", path)
  auth <- do_oauth()
  tt <- POST(url, config = c(token = auth, config), body=args)
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(content(tt)$message)
    if(content(tt)$status == "ERROR") stop(content(tt)$message)
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

do_PUT <- function(what, path, args, parse=FALSE, config=config) {
  url <- file.path("https://api.digitalocean.com/v2", path)
  auth <- do_oauth()
  tt <- PUT(url, config = c(token = auth, config), body=args)
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

do_DELETE <- function(path, config=NULL) {
  url <- file.path("https://api.digitalocean.com/v2", path)
  auth <- do_oauth()
  tt <- DELETE(url, config = c(token = auth, config))
  if(tt$status_code > 204){
    if(tt$status_code > 204) stop(content(tt)$message)
    if(content(tt)$status == "ERROR") stop(content(tt)$message)
  }
  if(http_status(tt)$category=='success'){
    message(http_status(tt)$message)
    invisible(http_status(tt)$message)
  } else { stop('Something went wrong') }
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
        retid <- x$droplet_ids[[1]]
      } else {
        retid <- as.numeric(as.character(x))
      }
      if(!is.numeric(retid)) stop("Could not detect a droplet id")

      # check actions, and wait if not 'completed' or 'errored' status
      if(!x$droplets$data$status[1] == 'active'){
        actiondat <- x['actions']
        if(is.na(actiondat)){ return( retid ) } else {
          if(!is.null(actiondat$actions$id)){
            actionid <- actiondat$actions$id
            if(length(actionid) > 1) actionid <- actionid[1]
            tocheck <- 0
            while(tocheck != 1){
              actioncheck <- actions(x = actionid)
              tocheck <- if(actioncheck$action$status %in% c('completed','errored')) 1 else 0
            }
            return( retid )
          } else { return( retid ) }
        }
      } else { return( retid) }
    } else { NULL }
  }
}

match_droplet <- function(x, id){
  if(length(x$droplet_ids) > 1){
    x$droplets$data <- x$droplets$data[ x$droplets$data$id %in% id, ]
    x$droplets$details <- x$droplets$details[ x$droplets$details$id %in% id, ]
  }
  x[ !names(x) %in% c('meta','actions') ]
}

parse_to_df <- function(tmp){
  if(length(tmp) == 1){
    tmp[[1]][vapply(tmp[[1]], is.null, logical(1))] <- NA
    data.frame(tmp[[1]], stringsAsFactors = FALSE)
  } else {
    do.call(rbind.fill, lapply(tmp[[1]], function(z){
      z[vapply(z, is.null, logical(1))] <- NA
      data.frame(z, stringsAsFactors = FALSE)
    }))
  }
}

#' Rate limit information for the authenticated user.
#'
#' @export
#' @param x input to print, a do_rate S3 object
#' @param ... Not used

do_rate_limit <- function(){
  url <- "https://api.digitalocean.com/v2/sizes"
  auth <- do_oauth()
  tt <- HEAD(url, config = list(token = auth))
  tmp <- as.numeric(tt$headers[c('ratelimit-limit','ratelimit-remaining','ratelimit-reset')])
  reset <- as.POSIXct(tmp[3], origin="1970-01-01")
  dat <- list(limit=tmp[1], remaining=tmp[2], reset=reset)
  class(dat) <- "do_rate"
  dat
}

#' @method print do_rate
#' @export
#' @rdname do_rate_limit
print.do_rate <- function(x, ...){
  cat("Rate limit:", x$limit, '\n')
  cat("Limit remaining:", x$remaining, '\n')
  cat("Reset time:", '\n')
  print(x$reset)
}
