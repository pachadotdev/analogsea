#' Get metadata on your ssh keys
#'
#' @export
#' @param ssh_key_id (numeric) An ssh key id (optional)
#' @template params
#' @examples \dontrun{
#' keys_get()
#' keys_get(ssh_key_id=89103)
#' }

keys_get <- function(ssh_key_id=NULL, what="parsed", ...)
{
  path <- if(is.null(ssh_key_id)) 'ssh_keys' else sprintf('ssh_keys/%s', ssh_key_id)
  res <- do_handle(what, path, ...)
  if(res$status == "OK") res[ !names(res) %in% "status" ]
}