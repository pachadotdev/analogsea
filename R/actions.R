#' Get metadata on all your droplets, or droplets by id
#'
#' @importFrom magrittr %>%
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @template params
#' @examples \dontrun{
#' actions()
#' actions(action_id='30841267')
#' actions(action_id='30219078')
#' }

actions <- function(action_id=NULL, what="parsed", ...)
{
  path <- if(is.null(action_id)) 'actions' else sprintf('actions/%s', action_id)
  tmp <- do_GET(what, FALSE, path, parse=TRUE, ...)
  tmp
}
