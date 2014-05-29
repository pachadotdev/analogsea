#' Get all the available sizes that can be used to create a droplet.
#'
#' @export
#' @param what (character) One of parsed (data.frame) or raw (httr response object)
#' @param callopts Curl options passed on to httr::GET
#' @return A data.frame with available sizes (RAM, disk, no. CPU's) and their costs
#' @examples \dontrun{
#' do_auth()
#' do_sizes()
#' res <- do_sizes('raw')
#' res$url
#' res$headers
#' }

do_sizes <- function(what='parsed', callopts=list())
{
  au <- do_get_auth()
  url <- 'https://api.digitalocean.com/v1/sizes'
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  res <- do_handle(what, url, args, callopts)
  if(what == 'raw'){ res } else {
    do.call(rbind, lapply(res$sizes, data.frame, stringsAsFactors = FALSE))
  }
}