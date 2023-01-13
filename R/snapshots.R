snapshot_url <- function(snapshot = NULL) {
  url("snapshots", snapshot)
}

#' @param x Object to coerce to an snapshot
#' @export
#' @rdname snapshots
as.snapshot <- function(x) UseMethod("as.snapshot")
#' @export
as.snapshot.list <- function(x) list_to_object(x, "snapshot")
#' @export
as.snapshot.snapshot <- function(x) x
#' @export
as.snapshot.numeric <- function(x) snapshot(x)
#' @export
as.snapshot.character <- function(x) {
  vv <- snapshots()
  vv[[which(
    x == unname(sapply(vv, "[[", "id"))
  )]]
}

#' Snapshot operations
#'
#' \describe{
#'  \item{snapshot}{retrieve a snapshot}
#'  \item{snapshots}{list snapshots, all, droplets, or volumes}
#'  \item{snapshot_delete}{delete a snapshot}
#' }
#'
#' @param snapshot A snapshot, or something that can be coerced to a snapshot by
#'   \code{\link{as.snapshot}}.
#' @param type (character) \code{NULL} (all snapshots), or one of droplet
#' (droplet snapshots) or volume (volume snapshots)
#' @param page Which 'page' of paginated results to return (default 1).
#' @param per_page Number of items returned per page (default 20, maximum 200)
#' @param id A snapshot id (varies depending on droplet or volume ID)
#' @param ... Additional options passed down to \code{\link[httr]{GET}},
#' \code{\link[httr]{POST}}, etc.
#' @examples \dontrun{
#' # list all snapshots
#' (res <- snapshots())
#'
#' # list droplet snapshots
#' snapshots(type = "droplet")
#'
#' # list volume snapshots
#' snapshots(type = "volume")
#'
#' # paging
#' snapshots(per_page = 5)
#' snapshots(per_page = 5, page = 2)
#'
#' # get a single snapshot
#' snapshot(res[[1]]$id)
#'
#' # delete a snapshot
#' ## a whole snapshot class object
#' snapshot_delete(res[[2]])
#' ## by id
#' snapshot_delete(res[[2]]$id)
#' ## by name
#' snapshot_delete(res[[2]]$name)
#'
#' # delete many snapshots
#' lapply(snapshots(), snapshot_delete)
#' }

#' @export
#' @rdname snapshots
snapshots <- function(type = NULL, page = 1, per_page = 20, ...) {
  per_page = max(per_page, 200)
  as.snapshot(
    do_GET(snapshot_url(), query = ascompact(list(resource_type = type,
                                                  page = page, 
                                                  per_page = per_page)), ...)
  )
}

#' @export
#' @rdname snapshots
snapshot <- function(id, ...) {
  res <- do_GET(snapshot_url(id), ...)
  list_to_object(res, "snapshot")
}

#' @export
#' @rdname snapshots
snapshot_delete <- function(snapshot, ...) {
  snap <- as.snapshot(snapshot)
  do_DELETE(snapshot_url(snap$id), ...)
}

#' @export
print.snapshot <- function(x, ...) {
  cat("<snapshot> ", x$name, " (", x$id, ")", "\n", sep = "")
  cat("  Descr.:    ", x$description, "\n")
  cat("  Region:    ", x$region$slug, "\n")
  cat("  Size (GB): ", x$size_gigabytes, "\n")
  cat("  Created:   ", x$created_at, "\n")
}
