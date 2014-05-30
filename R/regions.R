#' Get list of regions and their metadata
#' 
#' @export
#' @template params
#' @examples \dontrun{
#' regions()
#' regions('raw')
#' }

regions <- function(what="parsed", ...)
{
  res <- do_handle(what, path='regions', ...)
  if(what == 'raw'){ res } else {
    do.call(rbind, lapply(res$regions, data.frame, stringsAsFactors = FALSE))
  }
}