#' Get metadata on your ssh keys
#'
#' @export
#' @param ssh_key_id (numeric) An ssh key id (optional)
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_keys_get()
#' }

do_keys_get <- function(ssh_key_id=NULL, what="list", callopts=list())
{
  au <- do_get_auth()
  if(is.null(ssh_key_id)){
    url <- 'https://api.digitalocean.com/v1/ssh_keys'
  } else {
    url <- sprintf('https://api.digitalocean.com/v1/ssh_keys/%s', ssh_key_id)
  }
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}