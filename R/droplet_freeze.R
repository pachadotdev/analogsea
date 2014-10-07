#' Freeze or thaw a droplet.
#' 
#' All in one step, power off the droplet, snapshot to create an image, and delete the droplet.
#'
#' @param droplet A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param name Name for the image to be created, or to be used to create a new droplet. On image 
#' creation, defaults to a name assigned by Digital Ocean.
#' @param ... For freeze, further args passed on to \code{\link{droplet_shapshot}}, whereas for 
#' thaw, args passed on to \code{\link{droplet_new}}.
#' @export
#' @examples
#' \dontrun{
#' # freeze
#' droplet_new(region = 'nyc3') %>% droplet_freeze()
#' 
#' # thaw
#' droplet_thaw('chiromantical-1412718795', region='nyc3')
#' }

droplet_freeze <- function(droplet, name = NULL, ...) {
  droplet <- as.droplet(droplet)
  droplet %>% 
    droplet_power_off %>%
    droplet_snapshot(name = name, ...) %>%
    droplet_delete
}

#' @export
#' @rdname droplet_freeze
droplet_thaw <- function(name, ...) {
  imgs <- images(public = FALSE)
  if(!name %in% names(imgs)) stop(sprintf("%s not found", name), call. = FALSE)
  img <- imgs[ names(imgs) %in% name ]
  d <- droplet_new(image = img[[1]]$id, ...)
  as.droplet(d)
}
