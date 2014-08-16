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
  do_GET(what, path='regions', parse=if(what=='parsed') TRUE else FALSE, ...)
#   if(what == 'raw'){ res } else {
#     do.call(rbind, lapply(res$regions, data.frame, stringsAsFactors = FALSE))
#   }
}
