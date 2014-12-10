#' Reuse a droplet or image by name
#'
#' @export
#' @return A droplet
#' @param name A name that could be a droplet or image name
#' @param ... Named options passed on to \code{\link{droplet_create}}.
#' @examples \dontrun{
#' reuse(name = 'BeguiledAmmonia') # matches droplet that exists
#' reuse(name = 'hadleyverse1', size = "1gb") # matching image that exists
#' reuse(name = 'tablesandchairs') # no matching droplet or image
#' }

reuse <- function(name, ...) {
  drops <- droplets()
  imgs <- images(FALSE)
  if (name %in% names(drops)) {
    message(same)
    drops[[name]]
  } else if (name %in% names(imgs)) {
    message(fromimg)
    droplet_create(name, image = imgs[[name]]$id, ...)
  } else {
    message(freshnew)
    droplet_create(name, ...)
  }
}

same <- "droplet of same name already exists"
fromimg <- "image of same name, creating droplet..."
freshnew <- "no matched droplets or images, creating new droplet..."
