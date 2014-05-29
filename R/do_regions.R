#' Get list of regions and their metadata
#' 
#' @export
#' @param what (character) One of parsed (data.frame) or raw (httr response object)
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_regions()
#' do_regions('raw')
#' }

do_regions <- function(what="parsed", callopts=list())
{
  au <- do_get_auth()
  url <- 'https://api.digitalocean.com/v1/regions'
  args <- ct(client_id=au$id, api_key=au$key)
  res <- do_handle(what, url, args, callopts)
  if(what == 'raw'){ res } else {
    do.call(rbind, lapply(res$regions, data.frame, stringsAsFactors = FALSE))
  }
}