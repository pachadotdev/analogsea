#' Get information on an event
#'
#' @export
#' @param id Event ID.
#' @template params
#' @examples \dontrun{
#' events(id=25914777)
#' }

events <- function(id=NULL, what="parsed", ...)
{
  assert_that(!is.null(id))
  do_GET(what, TRUE, sprintf('events/%s', id), ...)
}