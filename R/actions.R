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
#' actions(per_page=2)
#' actions(per_page=2, page=2)
#' }

actions <- function(action_id=NULL, what="parsed", page=1, per_page=25, config=NULL)
{
  path <- if(is.null(action_id)) 'actions' else sprintf('actions/%s', action_id)
  do_GET(what, FALSE, path, query = ct(page=page, per_page=per_page), parse=TRUE, config=config)
}
