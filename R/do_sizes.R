#' Get all the available sizes that can be used to create a droplet.
#'
#' @export
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_sizes()
#' do.call(rbind, do_sizes()$sizes)
#' }

do_sizes <- function(what="list", callopts=list())
{
  au <- do_get_auth()
  url <- 'https://api.digitalocean.com/v1/sizes'
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}