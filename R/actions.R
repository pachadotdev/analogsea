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

as.action <- function(x) UseMethod("as.action")

#' @export
as.action.list <- function(x) {
  if (is.null(x$id)) stop("No action id found", call. = FALSE)
  
  structure(x, class = "action")
}
#' @export
as.action.action <- function(x) x

action_update <- function(action) {
  action <- as.action(action)
  
  path <- sprintf('droplets/%s/actions/%s', action$resource_id, action$id)
  res <- do_GET("parsed", path)
  as.action(res$action)
}

#' @export
print.action <- function(x, ...) {
  cat("<action> ", x$type, " (", x$id, ")\n", sep = "")
  cat("  Status: ", x$status, "\n", sep = "")
  cat("  Resource: ", x$resource_type, " ", x$resource_id, "\n", sep = "")  
}

is_complete <- function(x) {
  !is.null(x$completed_at)
}

#' @export
action_wait <- function(x) {
  if (is_complete(x)) return(droplet(x$resource_id))
  
  cat("Waiting for ", x$type, sep = "")
  while(!is_complete(x)) {
    x <- action_update(x)
    Sys.sleep(1)
    cat('.')
  }
  cat("\n")
  
  droplet(x$resource_id)
}
