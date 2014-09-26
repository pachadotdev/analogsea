#' Retrieve a single droplet.
#' 
#' @param id (integer) Droplet id.
#' @param x Object to coerce. Can be an integer (droplet id), string 
#'   (droplet name), a droplet (duh), or an action (which waits until 
#'   complete then returns the droplet)
#' @inheritParams droplets
#' @export
#' @examples
#' \dontrun{
#' droplet(1234)
#' 
#' as.droplet("my-favourite-droplet")
#' as.droplet(10)
#' as.droplet(droplets()[[1]])
#' }
droplet <- function(id, ...) {
  x <- do_GET(sprintf("droplets/%s", id), ...)
  structure(x$droplet, class = "droplet")
}

#' @export
#' @rdname droplet
as.droplet <- function(x) UseMethod("as.droplet")
#' @export
as.droplet.numeric <- function(x) droplets(x)
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
  cat("  Status: ", x$status, "\n", sep = "")
  cat("  Region: ", x$region$name, "\n", sep = "")
  cat("  Image: ", x$image$name, "\n", sep = "")
  cat("  Size: ", x$size$slug, " ($", x$size$price_hourly, " / hr)" ,"\n", sep = "") 
}
