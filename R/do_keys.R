#' Get metadata on your ssh keys
#'
#' @export
#' @param ssh_key_id (numeric) An ssh key id (optional)
#' @template params
#' @examples \dontrun{
#' do_auth()
#' do_keys_get()
#' do_keys_get(ssh_key_id=89103)
#' }

do_keys_get <- function(ssh_key_id=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  path <- if(is.null(ssh_key_id)) 'ssh_keys' else sprintf('ssh_keys/%s', ssh_key_id)
  res <- do_handle(what, path, ...)
  if(res$status == "OK") res[ !names(res) %in% "status" ]
}