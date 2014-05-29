#' Get list of regions and their metadata
#' 
#' @export
#' @template params
#' @examples \dontrun{
#' do_auth()
#' do_regions()
#' do_regions('raw')
#' }

do_regions <- function(what="parsed", ...)
{
  au <- do_get_auth()
  res <- do_handle(what, 'regions', ...)
  if(what == 'raw'){ res } else {
    do.call(rbind, lapply(res$regions, data.frame, stringsAsFactors = FALSE))
  }
}