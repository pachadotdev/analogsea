#' @param x Object to coerce to an database
#' @export
#' @rdname databases
as.database <- function(x) UseMethod("as.database")
#' @export
as.database.list <- function(x) list_to_object(x, "database")
#' @export
as.database.database <- function(x) x
#' @export
as.database.numeric <- function(x) database(x)
#' @export
as.database.character <- function(x) {
  if (!grepl("[A-Za-z0-9]+-[A-Za-z0-9]+-[A-Za-z0-9]+-[A-Za-z0-9]+-[A-Za-z0-9]+",
             x)) {
    databases()[[x]]
  } else {
    vv <- databases()
    vv[[which(
      x == unname(vapply(vv, "[[", "", "id"))
    )]]
  }
}

#' Block storage operations
#'
#' \describe{
#'  \item{database}{get a single database}
#'  \item{databases}{list databases}
#'  \item{database_create}{create a database}
#'  \item{database_snapshot_create}{create a snapshot of a database}
#'  \item{database_snapshots}{list snapshots for a database}
#'  \item{database_delete}{delete a database}
#' }
#'
#' @param database A database, or something that can be coerced to a database by
#'   \code{\link{as.database}}.
#' @param name (character) Name of the new database. required.
#' @param size (integer) The size of the Block Storage database in GiB
#' @param description (character) An optional free-form text field to describe
#' a Block Storage database.
#' @param region (character) The region where the Block Storage database will
#' be created. When setting a region, the value should be the slug identifier
#' for the region. When you query a Block Storage database, the entire region
#' object will be returned. Should not be specified with a snapshot_id.
#' Default: nyc1
#' @param snapshot_id (integer) The unique identifier for the database snapshot
#' from which to create the database. Should not be specified with a region_id.
#' @param engine (character) The name of the engine type to be
#' used on the database. When provided, the database will be
#' created with the specified backend type. Currently, the available
#' options are "pg", "mysql", "redis" and "mongodb".
#' @param tags (character) tag names to apply to the database after it is created.
#' Tag names can either be existing or new tags.
#' @param ... Additional options passed down to \code{\link[httr]{GET}},
#' \code{\link[httr]{POST}}, etc.
#' @details  note that if you delete a database, and it has a snapshot, the
#' snapshot still exists, so beware
#' @examples \dontrun{
#' # list databases
#' databases()
#'
#' # create a database
#' vol1 <- database_create('testing', 5)
#' vol2 <- database_create('foobar', 6, tags = c('stuff', 'things'))
#'
#' # create snapshot of a database
#' xx <- database_snapshot_create(vol2, "howdy")
#'
#' # list snaphots for a database
#' database_snapshots(xx)
#'
#' # list databases again
#' res <- databases()
#'
#' # get a single database
#' ## a whole database class object
#' database(res$testing)
#' ## by id
#' database(res[[1]]$id)
#' ## by name
#' database(res[[1]]$name)
#'
#' # delete a database
#' ## a whole database class object
#' database_delete(res$testing)
#' ## by id
#' database_delete(res[[1]]$id)
#' ## by name
#' database_delete(res[[1]]$name)
#'
#' # delete many databases
#' lapply(databases(), database_delete)
#' }

#' @export
#' @rdname databases
databases <- function(...) {
  res <- do_GET('databases', ...)
  as.database(res)
}

#' @export
#' @rdname databases
database <- function(database, ...) {
  vol <- as.database(database)
  res <- do_GET(database_url(vol$id), ...)
  list_to_object(res, "database")
}

#' @export
#' @rdname databases
database_create <- function(name, size, description = NULL, region = 'nyc1',
                            snapshot_id = NULL, engine = NULL,
                            tags = NULL, ...) {
  body <- ascompact(list(name = name, size_gigabytes = size,
                         description = description, region = region, snapshot_id = snapshot_id,
                         engine = engine,
                         tags = tags))
  as.database(do_POST("databases", ..., body = body))
}

#' @export
#' @rdname databases
database_snapshot_create <- function(database, name, ...) {
  vol <- as.database(database)
  res <- do_POST(sprintf("databases/%s/snapshots", vol$id), ...,
                 body = list(name = name))
  list_to_object(res, "snapshot", class = "database_snapshot")
}

#' @export
#' @rdname databases
database_snapshots <- function(database, ...) {
  vol <- as.database(database)
  res <- do_GET(sprintf("databases/%s/snapshots", vol$id), ...)
  list_to_object(res, "snapshot", class = "database_snapshot")
}

#' @export
#' @rdname databases
database_delete <- function(database, ...) {
  vol <- as.database(database)
  do_DELETE(paste0('databases/', vol$id), ...)
}


#' @export
print.database <- function(x, ...) {
  cat("<database> ", x$name, " (", x$id, ")", "\n", sep = "")
  cat("  Descr.:    ", x$description, "\n")
  cat("  Region:    ", x$region$slug, "\n")
  cat("  Size (GB): ", x$size_gigabytes, "\n")
  cat("  Created:   ", x$created_at, "\n")
}

#' @export
print.database_snapshot <- function(x, ...) {
  cat("<database - snapshot> ", x$name, " (", x$id, ")", "\n", sep = "")
  cat("  Regions:             ", paste0(unlist(x$regions), collapse = ", "),
      "\n")
  cat("  Min. Disk Size (GB): ", x$min_disk_size, "\n")
  cat("  Size (GB):           ", x$size_gigabytes, "\n")
  cat("  Created:             ", x$created_at, "\n")
}
