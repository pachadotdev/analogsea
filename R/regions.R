#' Get list of regions and their metadata
#' 
#' @export
#' @template params
#' @examples \dontrun{
#' do_auth()
#' regions()
#' regions('raw')
#' }

regions <- function(what="parsed", ...)
{
  au <- do_get_auth()
  res <- do_handle(what, 'regions', ...)
  if(what == 'raw'){ res } else {
    do.call(rbind, lapply(res$regions, data.frame, stringsAsFactors = FALSE))
  }
}