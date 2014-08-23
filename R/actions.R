#' Get metadata on all your droplets, or droplets by id
#'
#' @importFrom magrittr %>%
#' @export
#' @param x An action id, a droplet with action ids, or nothing, in which case all action ids 
#' associated with your account are returned.
#' @template params
#' @examples \dontrun{
#' actions()
#' actions(x=30841267)
#' actions(30219078)
#' actions(per_page=75)
#' actions(per_page=2, page=2)
#' 
#' droplets(2376676) %>% actions
#' droplets() %>% actions
#' }

actions <- function(x=NULL, what="parsed", page=1, per_page=25, config=NULL)
{
  action_id <- check_action(x)
  path <- if(is.null(action_id)) 'actions' else sprintf('actions/%s', action_id)
  res <- do_GET(what, path, ct(page=page, per_page=per_page), TRUE, config)
  parse_action(res$action)
}

check_action <- function(x){
  if(!is.null(x)){
    if(is.list(x)){
      if(is.null(x$actions$id)) stop("No action id found", call. = FALSE)
      x <- x$actions$id
      if(!is.numeric(x)) stop("Could not detect a action id", call. = FALSE)
    } else {
      x <- as.numeric(as.character(x))
      if(!is.numeric(x)) stop("Could not detect an action id", call. = FALSE)
    }
    x
  } else { NULL }
}

parse_action <- function(x){
  x[sapply(x, is.null)] <- NA
  data.frame(x, stringsAsFactors = FALSE)
}
