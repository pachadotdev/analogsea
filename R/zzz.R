#' Get request and output result or errors
#' 
#' @export
#' @param url URL for the call
#' @param args Arguments to GET
#' @param curl Callopts
#' @return Some combination of warnings and httr response object or list
do_handle <- function(url, args, curl){
  tt <- GET(url, query=args, curl)
  warn_for_status(tt)
  res <- content(tt, as = "text")
  if(what=='list') fromJSON(res, FALSE) else tt
}

#' Compact
#' 
#' @export
#' @param l List input
do_compact <- function (l) Filter(Negate(is.null), l)