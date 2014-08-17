#' Get all the available sizes that can be used to create a droplet.
#'
#' @export
#' @template params
#' @return A data.frame with available sizes (RAM, disk, no. CPU's) and their costs
#' @examples \dontrun{
#' sizes()
#' sizes(per_page=2)
#' res <- sizes('raw')
#' res$url
#' res$headers
#' }

sizes <- function(what='parsed', page=1, per_page=25, config=NULL)
{
  do_GET(what, path='sizes', 
         query = ct(page=page, per_page=per_page),
         parse=if(what=='parsed') TRUE else FALSE, config=config)
}
