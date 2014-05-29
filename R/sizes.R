#' Get all the available sizes that can be used to create a droplet.
#'
#' @export
#' @template params
#' @return A data.frame with available sizes (RAM, disk, no. CPU's) and their costs
#' @examples \dontrun{
#' do_auth()
#' sizes()
#' res <- sizes('raw')
#' res$url
#' res$headers
#' }

sizes <- function(what='parsed', ...)
{
  au <- do_get_auth()
  res <- do_handle(what, 'sizes', ...)
  if(what == 'raw'){ res } else {
    do.call(rbind, lapply(res$sizes, data.frame, stringsAsFactors = FALSE))
  }
}