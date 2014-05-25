#' Get list of regions and their metadata
#' 
#' @export
#' @param what One of lit or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_regions()
#' }

do_regions <- function(what="list", callopts=list())
{
  au <- do_get_auth()
  url <- 'https://api.digitalocean.com/v1/regions'
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}