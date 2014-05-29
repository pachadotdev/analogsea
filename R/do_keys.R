#' Get metadata on your ssh keys
#'
#' @export
#' @param ssh_key_id (numeric) An ssh key id (optional)
#' @param what (character) One of parsed (list) or raw (httr response object)
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_keys_get()
#' do_keys_get(ssh_key_id=89103)
#' }

do_keys_get <- function(ssh_key_id=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()
  if(is.null(ssh_key_id)){
    url <- 'https://api.digitalocean.com/v1/ssh_keys'
  } else {
    url <- sprintf('https://api.digitalocean.com/v1/ssh_keys/%s', ssh_key_id)
  }
  args <- ct(client_id=au$id, api_key=au$key)
  res <- do_handle(what, url, args, callopts)
  if(res$status == "OK") res[ !names(res) %in% "status" ]
}