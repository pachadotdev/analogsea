#' Freeze/thaw droplets.
#' 
#' Freeze powers off the droplet, snapshots to create an image, and deletes the 
#' droplet. Thaw performs the inverse: it takes an image and turns it into
#' a running droplet.
#' 
#' @param droplet A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param name Name for the image to be created, or to be used to create a 
#'   new droplet. Defaults to name of the droplet.
#' @param image Image to thaw into a droplet.
#' @param ... For freeze, further args passed on to 
#'   \code{\link{droplet_snapshot}}; thaw, args passed on to 
#'  \code{\link{droplet_create}}.
#' @return \code{droplet_freeze} accepts a droplet as first 
#'   argument, and returns an image; \code{droplet_thaw} does the opposite:
#'   it accepts an image as first argument, and returns a droplet.
#' @export
#' @examples
#' \dontrun{
#' # freeze
#' droplet_create(region = 'nyc3') %>% droplet_freeze()
#' 
#' # thaw
#' droplet_thaw(image='chiromantical-1412718795', region='nyc3')
#' }
droplet_freeze <- function(droplet, name = droplet$name, ...) {
  droplet <- as.droplet(droplet)
  
  droplet %>% 
    droplet_power_off() %>%
    droplet_snapshot(name = name) %>% 
    action_wait()
  
  # Find image that was just created
  imgs <- droplet %>% droplet_snapshots_list()
  image <- Filter(function(x) identical(name, x$name), imgs)[[1]]
  
  droplet %>% droplet_delete()
  image
}

#' @export
#' @rdname droplet_freeze
droplet_thaw <- function(image, ...) {
  image <- as.image(image)
  droplet_create(image = image$id, ...)
}
