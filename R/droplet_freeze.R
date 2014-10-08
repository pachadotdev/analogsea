#' Freeze or thaw a droplet.
#' 
#' All in one step, power off the droplet, snapshot to create an image, and delete the droplet.
#'
#' @param droplet A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param name Name for the image to be created, or to be used to create a new droplet. On image 
#' creation, defaults to a name assigned by Digital Ocean.
#' @param image An image to modify.
#' @param ... For freeze, further args passed on to \code{\link{droplet_snapshot}}, whereas for 
#' thaw, args passed on to \code{\link{droplet_new}}.
#' @export
#' @details freeze accepts a droplet as first argument, and returns an image. 
#' thaw accepts an image as first argument, and returns a droplet.
#' @examples
#' \dontrun{
#' # freeze
#' droplet_new(region = 'nyc3') %>% droplet_freeze()
#' 
#' # thaw
#' droplet_thaw(image='chiromantical-1412718795', region='nyc3')
#' }

droplet_freeze <- function(droplet, name = droplet$name, ...) {
  droplet <- as.droplet(droplet)
  droplet %>% 
    droplet_power_off %>%
    droplet_snapshot(name = name) %>%
    action_wait
  droplet %>% droplet_delete
  imgs <- droplet %>% droplet_snapshots_list
  imgid <- Filter(function(x) grepl(name, x$name), imgs)[[1]]$id
  image(imgid)
}

#' @export
#' @rdname droplet_freeze
droplet_thaw <- function(image, ...) {
  image <- as.image(image)
  droplet_new(image = image$id, ...)
}
