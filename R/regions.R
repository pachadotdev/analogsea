#' Get list of regions and their metadata
#' 
#' @export
#' @template params
#' @examples \dontrun{
#' regions()
#' regions(per_page=2)
#' regions('raw')
#' }

regions <- function(what="parsed", page=1, per_page=25, ...)
{
  do_GET(what, path='regions',
         query = ct(page=page, per_page=per_page), 
         parse=if(what=='parsed') TRUE else FALSE, ...)
#   if(what == 'raw'){ res } else {
#     do.call(rbind, lapply(res$regions, data.frame, stringsAsFactors = FALSE))
#   }
}
