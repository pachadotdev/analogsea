#' List actions across all droplets.
#'
#' "Actions are records of events that have occurred on the resources in your 
#' account. These can be things like rebooting a Droplet, or transferring an 
#' image to a new region."
#' 
#' "An action object is created every time one of these actions is initiated. 
#' The action object contains information about the current status of the 
#' action, start and complete timestamps, and the associated resource type and 
#' ID."
#'
#' "Every action that creates an action object is available through this 
#' endpoint. Completed actions are not removed from this list and are always 
#' available for querying."
#'
#' @export
#' @inheritParams droplets
#' @examples \dontrun{
#' actions()
#' }
actions <- function(...) {
  res <- do_actions(...) 
  lapply(res$actions, as.action)
}

#' @export
#' @rdname actions
do_actions <- function(page = 1, per_page = 25, config = NULL) {
  do_GET("parsed", "actions", 
    list(page = page, per_page = per_page),
    config = config
  )
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
