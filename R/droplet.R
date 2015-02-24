#' Retrieve a single droplet.
#'
#' @param id (integer) Droplet id.
#' @param x Object to coerce. Can be an integer (droplet id), string
#'   (droplet name), a droplet (duh), or an action (which waits until
#'   complete then returns the droplet)
#' @param object Droplet object to pass to \code{summary}
#' @inheritParams droplets
#' @export
#' @examples
#' \dontrun{
#' droplet(1234)
#'
#' as.droplet("my-favourite-droplet")
#' as.droplet(10)
#' as.droplet(droplets()[[1]])
#'
#' droplet(1234) %>% summary
#' }
droplet <- function(id, ...) {
  x <- do_GET(sprintf("droplets/%s", id), ...)
  structure(x$droplet, class = "droplet")
}

#' @export
#' @rdname droplet
as.droplet <- function(x) UseMethod("as.droplet")
#' @export
as.droplet.numeric <- function(x) droplet(x)
#' @export
as.droplet.character <- function(x) droplets()[[x]]
#' @export
as.droplet.droplet <- function(x) x
#' @export
as.droplet.action <- function(x) {
  if (x$resource_type != "droplet") {
    stop("Resource type: ", x$resource_type, call. = FALSE)
  }

  action_wait(x)
}

#' @export
print.droplet <- function(x, ...) {
  cat("<droplet>", x$name, " (", x$id, ")\n", sep = "")
  cat("  IP:     ", droplet_ip(x), "\n", sep = "")
  cat("  Status: ", x$status, "\n", sep = "")
  cat("  Region: ", x$region$name, "\n", sep = "")
  cat("  Image:  ", x$image$name, "\n", sep = "")
  cat("  Size:   ", x$size_slug, "\n", sep = "")
}

#' @export
#' @rdname droplet
summary.droplet <- function(object, ...) {
  # price <- get_price(object$size)$price_hourly
  price <- object$size$price_hourly
  crat <- as.POSIXct(strptime(object$created_at, "%Y-%m-%dT%H:%M:%S", "UTC"))
  now <- as.POSIXlt(Sys.time(), "UTC")
  cost <- round(difftime(now, crat, units = "hours")[[1]] * price, 3)

  cat("<droplet_detail>", object$name, " (", object$id, ")\n", sep = "")
  cat("  Status: ", object$status, "\n", sep = "")
  cat("  Region: ", object$region$name, "\n", sep = "")
  cat("  Image: ", object$image$name, "\n", sep = "")
  cat("  Size: ", object$size_slug, " ($", price, " / hr)" ,"\n", sep = "")
  cat("  Estimated cost ($): ", cost, "\n", sep = "")
  cat("  Locked: ", object$locked, "\n", sep = "")
  cat("  Created at: ", object$created_at, " UTC", "\n", sep = "")
  cat("  Networks: ", "\n", sep = "")
  cat("     v4: ", make_list(object$networks$v4), "\n", sep = "")
  cat("     v6: ", make_list(object$networks$v6), "\n", sep = "")
  cat("  Kernel: ", make_list(list(object$kernel)), "\n")
  cat("  Snapshots: ", unlist(object$snapshot_ids), "\n")
  cat("  Backups: ", unlist(object$backup_ids), "\n")
}

make_list <- function(y){
  if(length(y) > 0){
    y <- y[[1]]
    out <- list()
    for(i in seq_along(y)){
      out[[i]] <- paste0(names(y)[i], " (", y[i], ")")
    }
    paste0(out, collapse = ", ")
  } else { "none" }
}
