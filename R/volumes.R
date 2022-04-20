volume_url <- function(volume = NULL) {
  url("volumes", volume)
}

#' @param x Object to coerce to an volume
#' @export
#' @rdname volumes
as.volume <- function(x) UseMethod("as.volume")
#' @export
as.volume.list <- function(x) list_to_object(x, "volume")
#' @export
as.volume.volume <- function(x) x
#' @export
as.volume.numeric <- function(x) volume(x)
#' @export
as.volume.character <- function(x) {
  if (!grepl("[A-Za-z0-9]+-[A-Za-z0-9]+-[A-Za-z0-9]+-[A-Za-z0-9]+-[A-Za-z0-9]+",
             x)) {
    volumes()[[x]]
  } else {
    vv <- volumes()
    vv[[which(
      x == unname(vapply(vv, "[[", "", "id"))
    )]]
  }
}

#' Block storage operations
#'
#' \describe{
#'  \item{volume}{get a single volume}
#'  \item{volumes}{list volumes}
#'  \item{volume_create}{create a volume}
#'  \item{volume_snapshot_create}{create a snapshot of a volume}
#'  \item{volume_snapshots}{list snapshots for a volume}
#'  \item{volume_delete}{delete a volume}
#' }
#'
#' @param volume A volume, or something that can be coerced to a volume by
#'   \code{\link{as.volume}}.
#' @param name (character) Name of the new volume. required.
#' @param size (integer) The size of the Block Storage volume in GiB
#' @param description (character) An optional free-form text field to describe
#' a Block Storage volume.
#' @param region (character) The region where the Block Storage volume will
#' be created. When setting a region, the value should be the slug identifier
#' for the region. When you query a Block Storage volume, the entire region
#' object will be returned. Should not be specified with a snapshot_id.
#' Default: nyc1
#' @param snapshot_id (integer) The unique identifier for the volume snapshot
#' from which to create the volume. Should not be specified with a region_id.
#' @param filesystem_type (character) The name of the filesystem type to be
#' used on the volume. When provided, the volume will automatically be
#' formatted to the specified filesystem type. Currently, the available
#' options are "ext4" and "xfs". Pre-formatted volumes are automatically
#' mounted when attached to Ubuntu, Debian, Fedora, Fedora Atomic, and
#' CentOS Droplets created on or after April 26, 2018. Attaching
#' pre-formatted volumes to other Droplets is not recommended.
#' @param filesystem_label (character) The label to be applied to the
#' filesystem. Labels for ext4 type filesystems may contain 16 characters
#' while lables for xfs type filesystems are limited to 12 characters.
#' May only be used in conjunction with filesystem_type.
#' @param tags (character) tag names to apply to the Volume after it is created.
#' Tag names can either be existing or new tags.
#' @param ... Additional options passed down to \code{\link[httr]{GET}},
#' \code{\link[httr]{POST}}, etc.
#' @details  note that if you delete a volume, and it has a snapshot, the
#' snapshot still exists, so beware
#' @examples \dontrun{
#' # list volumes
#' volumes()
#'
#' # create a volume
#' vol1 <- volume_create('testing', 5)
#' vol2 <- volume_create('foobar', 6, tags = c('stuff', 'things'))
#'
#' # create snapshot of a volume
#' xx <- volume_snapshot_create(vol2, "howdy")
#'
#' # list snaphots for a volume
#' volume_snapshots(xx)
#'
#' # list volumes again
#' res <- volumes()
#'
#' # get a single volume
#' ## a whole volume class object
#' volume(res$testing)
#' ## by id
#' volume(res[[1]]$id)
#' ## by name
#' volume(res[[1]]$name)
#'
#' # delete a volume
#' ## a whole volume class object
#' volume_delete(res$testing)
#' ## by id
#' volume_delete(res[[1]]$id)
#' ## by name
#' volume_delete(res[[1]]$name)
#'
#' # delete many volumes
#' lapply(volumes(), volume_delete)
#' }

#' @export
#' @rdname volumes
volumes <- function(...) {
  res <- do_GET('volumes', ...)
  as.volume(res)
}

#' @export
#' @rdname volumes
volume <- function(volume, ...) {
  vol <- as.volume(volume)
  res <- do_GET(volume_url(vol$id), ...)
  list_to_object(res, "volume")
}

#' @export
#' @rdname volumes
volume_create <- function(name, size, description = NULL, region = 'nyc1',
                          snapshot_id = NULL, filesystem_type = NULL,
                          filesystem_label = NULL, tags = NULL, ...) {
  body <- ascompact(list(name = name, size_gigabytes = size,
    description = description, region = region, snapshot_id = snapshot_id,
    filesystem_type = filesystem_type,
    filesystem_label = filesystem_label, tags = tags))
  as.volume(do_POST("volumes", ..., body = body))
}

#' @export
#' @rdname volumes
volume_snapshot_create <- function(volume, name, ...) {
  vol <- as.volume(volume)
  res <- do_POST(sprintf("volumes/%s/snapshots", vol$id), ...,
                 body = list(name = name))
  list_to_object(res, "snapshot", class = "volume_snapshot")
}

#' @export
#' @rdname volumes
volume_snapshots <- function(volume, ...) {
  vol <- as.volume(volume)
  res <- do_GET(sprintf("volumes/%s/snapshots", vol$id), ...)
  list_to_object(res, "snapshot", class = "volume_snapshot")
}

#' @export
#' @rdname volumes
volume_delete <- function(volume, ...) {
  vol <- as.volume(volume)
  do_DELETE(paste0('volumes/', vol$id), ...)
}


#' @export
print.volume <- function(x, ...) {
  cat("<volume> ", x$name, " (", x$id, ")", "\n", sep = "")
  cat("  Descr.:    ", x$description, "\n")
  cat("  Region:    ", x$region$slug, "\n")
  cat("  Size (GB): ", x$size_gigabytes, "\n")
  cat("  Created:   ", x$created_at, "\n")
}

#' @export
print.volume_snapshot <- function(x, ...) {
  cat("<volume - snapshot> ", x$name, " (", x$id, ")", "\n", sep = "")
  cat("  Regions:             ", paste0(unlist(x$regions), collapse = ", "),
      "\n")
  cat("  Min. Disk Size (GB): ", x$min_disk_size, "\n")
  cat("  Size (GB):           ", x$size_gigabytes, "\n")
  cat("  Created:             ", x$created_at, "\n")
}
