#' Get information on an event
#'
#' @export
#' @param x Event ID or a droplet object.
#' @param what (character) One of 'parsed' or 'raw'.
#' @param ... Not used.
#' @examples \dontrun{
#' events(x=26024501)
#' gg <- droplets() %>% droplets_power_on
#' events(x=gg)
#'
#' droplets() %>% droplets_power_off %>% events
#' }

events <- function(x=NULL, what="parsed", ...)
{
  .Defunct("actions", package = "analogsea", "events() is deprecated, see actions()")
#   id <- check_event(x)
#   assert_that(!is.null(id))
#   do_GET(what, TRUE, sprintf('events/%s', id), ...)
}

check_event <- function(x){
  if(!is.null(x)){
    if(is.list(x)){
      if(is.null(x$event_id)) stop("No event id found")
      x <- x$event_id
      if(!is.numeric(x)) stop("Could not detect a event id")
    } else {
      x <- as.numeric(as.character(x))
      if(!is.numeric(x)) stop("Could not detect an event id")
    }
    x
  } else { NULL }
}
