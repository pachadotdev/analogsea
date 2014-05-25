#' Get list of images and their metadata
#'  
#' @export
#' @param filter Filter stuff, one of my_images or global
#' @param what One of lit or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_images()
#' do_images(filter='my_images')
#' }

do_images <- function(filter=NULL, what="list", callopts=list())
{
  au <- do_get_auth()
  url <- 'https://api.digitalocean.com/v1/images'
  args <- do_compact(list(filter=filter, client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}