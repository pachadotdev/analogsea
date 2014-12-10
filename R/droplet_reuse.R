#' Reuse a droplet or image by name
#'
#' @export
#' @return A droplet
#' @param name A name that could be a droplet or image name
#' @param ... Named options passed on to \code{\link{droplet_create}}.
#' @examples \dontrun{
#' droplet_reuse(name = 'BeguiledAmmonia') # matches droplet that exists
#' droplet_reuse(name = 'hadleyverse1', size = "1gb") # matching image that exists
#' droplet_reuse(name = 'tablesandchairs') # no matching droplet or image
#' }

droplet_reuse <- function(name, ...) {
  drops <- droplets()
  imgs <- images(FALSE)
  if (name %in% names(drops)) {
    message("droplet of same name already exists")
    drops[[name]]
  } else if (name %in% names(imgs)) {
    message("image of same name, creating droplet...")
    droplet_create(name, image = imgs[[name]]$id, ...)
  } else {
    message("no matched droplets or images, creating new droplet...")
    droplet_create(name, ...)
  }
}
