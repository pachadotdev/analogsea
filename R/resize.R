#' Resize a droplet by power off, snapshot, and create new droplet
#'
#' @export
#' @param droplet A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param delete_original (logical) Delete original droplet. Default: \code{TRUE}
#' @param ... Named options passed on to \code{\link{droplet_create}}.
#' @return A droplet
#' @details Note that you can not resize a droplet while it is powered on.
#' Thus, this function powers off your droplet, makes a snapshot, then
#' creates a new droplet from that snapshot. We use \code{\link{droplet_wait}}
#' in between these steps to wait for each to finish. You can optionally delete
#' the original droplet.
#' @examples \dontrun{
#' d <- droplet_create()
#' d # current size is 512mb
#' d %>% resize(size = "2gb")
#' }

resize <- function(droplet, delete_original = TRUE, ...) {
  droplet <- as.droplet(droplet)
  droplet %>%
    droplet_power_off() %>%
    droplet_wait() %>%
    droplet_snapshot() %>%
    droplet_wait()
  snaps <- droplet %>% droplet_snapshots_list()
  newdrop <- droplet_create(image = snaps[length(snaps)][[1]]$id, ...)
  if (delete_original) droplet_delete(droplet)
  return(newdrop)
}
