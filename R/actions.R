action_url <- function(action = NULL) {
  url("actions", action)
}

as.action <- function(x) UseMethod("as.action")
#' @export
as.action.list <- function(x) list_to_object(x, "action", name = NULL)
#' @export
as.action.action <- function(x) x

#' @export
as.url.action <- function(x, ...) action_url(x$id)

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
  as.action(do_GET(action_url(), ...))
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
#' @rdname actions
#' @param x Input object
action_wait <- function(x) {
  if (is_complete(x)) return(droplet(x$resource_id))

  cat("Waiting for ", x$type, sep = "")
  while(!is_complete(x)) {
    x <- action_refresh(x)
    Sys.sleep(1)
    cat('.')
  }
  cat("\n")

  droplet(x$resource_id)
}


action_refresh <- function(action) {
  action <- as.action(action)
  as.action(do_GET("parsed", action))
}
