#' Attach a volume to a droplet
#'
#' @param volume A volume, or something that can be coerced to a volume by
#'   \code{\link{as.volume}}.
#' @param droplet A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param region (character) The region where the Block Storage volume will
#' be created. When setting a region, the value should be the slug identifier
#' for the region. When you query a Block Storage volume, the entire region
#' object will be returned. Should not be specified with a snapshot_id.
#' Default: nyc1
#' @param actionid (integer) Optional. An action id.
#' @param page Page to return. Default: 1.
#' @param per_page Number of results per page. Default: 25.
#' @param ... Additional options passed down to \code{\link[httr]{GET}},
#' \code{\link[httr]{POST}}, etc.
#'
#' @details Note that there is a way to attach a volume to or remove from a
#' droplet by name, but we only support doing this by ID. Howevever, as
#' the user, all you need to do is make a volume class object via
#' \code{\link{as.volume}} and pass it to \code{volume_attach} or
#' \code{volume_detach}, which is pretty darn easy.
#'
#' @examples \dontrun{
#' # resize a volume
#' ## create a volume
#' (vol1 <- volume_create('foobar', 5))
#' ## resize it
#' volume_resize(vol1, 6)
#' volume(vol1)
#'
#' # attach a volume to a droplet
#' ## create a droplet
#' (d <- droplet_create(region = "nyc1"))
#' ## attach volume to droplet
#' volume_attach(vol1, d)
#' ## refresh droplet info, see volumes slot
#' droplet(d$id)
#'
#' # detach a volume from a droplet
#' (act <- volume_detach(vol1, d))
#' ## refresh droplet info, see volumes slot
#' droplet(d$id)
#'
#' # list an action
#' volume_action(vol1, 154689758)
#'
#' # list all volume actions
#' volume_actions(volumes()[[1]])
#' }

#' @export
#' @rdname volume-actions
volume_attach <- function(volume, droplet, region = "nyc1", ...) {
  vol <- as.volume(volume)
  drop <- as.droplet(droplet)
  res <- do_POST(
    sprintf('volumes/%s/actions', vol$id),
    body = list(type = "attach", droplet_id = drop$id, region = region),
    ...)
  as.action(res)
}

#' @export
#' @rdname volume-actions
volume_detach <- function(volume, droplet, region = "nyc1", ...) {
  vol <- as.volume(volume)
  drop <- as.droplet(droplet)
  res <- do_POST(
    sprintf('volumes/%s/actions', vol$id),
    body = list(type = "detach", droplet_id = drop$id, region = region),
    ...)
  as.action(res)
}

#' @export
#' @rdname volume-actions
volume_resize <- function(volume, size, region = 'nyc1', ...) {
  vol <- as.volume(volume)
  res <- do_POST(
    sprintf('volumes/%s/actions', vol$id),
    body = list(type = "resize", size_gigabytes = size, region = region),
    ...)
  as.action(res)
}

#' @export
#' @rdname volume-actions
volume_action <- function(volume, actionid, ...) {
  vol <- as.volume(volume)
  as.action(do_GET(sprintf("volumes/%s/actions/%s", vol$id, actionid), ...))
}

#' @export
#' @rdname volume-actions
volume_actions <- function(volume, page = 1, per_page = 25, ...) {
  vol <- as.volume(volume)
  as.action(
    do_GET(
      sprintf("volumes/%s/actions", vol$id),
      query = list(page = page, per_page = per_page),
      ...
    )
  )
}
