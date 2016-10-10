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
#' @param snapshot_id (integer) The unique identifier for the snapshot snapshot
#' from which to create the snapshot. Should not be specified with a region_id.
#' @param ... Additional options passed down to \code{\link[httr]{GET}},
#' \code{\link[httr]{POST}}, etc.
#' @details  note that if you delete a snapshot, and it has a snapshot, the
#' snapshot still exists, so beware
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
snapshots <- function(type = NULL, ...) {
  as.snapshot(
    do_GET(snapshot_url(), query = ascompact(list(resource_type = type)), ...)
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
