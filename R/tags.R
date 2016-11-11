#' Create a tag
#'
#' @export
#' @param name (character) Name of the tag
#' @param ... Additional options passed down to \code{\link[httr]{POST}}
#' @return A tag object
#' @examples \dontrun{
#' tag_create(name = "venus")
#' }
tag_create <- function(name, ...) {
  as.tag(do_POST(url = 'tags', body = list(name = name), encode = NULL, ...))
}

#' Delete a tag
#'
#' @export
#' @param name (character) Name of the tag
#' @param ... Additional options passed down to \code{\link[httr]{DELETE}}
#' @return nothing, if succesful
#' @examples \dontrun{
#' tag_delete(name = "helloworld")
#' }
tag_delete <- function(name, ...) {
  name <- as.tag(name)
  do_DELETE(url = paste0('tags/', name$name), ...)
}

#' Rename a tag
#'
#' @export
#' @param name (character) Name of the tag
#' @param name_new (character) New name of the tag
#' @param ... Additional options passed down to \code{\link[httr]{PUT}}
#' @return A tag object
#' @examples \dontrun{
#' tag_rename("helloworld", "hellohello")
#' }
tag_rename <- function(name, name_new, ...) {
  as.tag(do_PUT(url = paste0('tags/', name), body = list(name = name_new),
                encode = NULL, ...))
}

#' Tag a resource
#'
#' @export
#' @param name (character) Name of the tag
#' @param resource_id (integer) a droplet id
#' @param resource_type (character) only "droplet" for now. Default: "droplet"
#' @param resources (list) instead of \code{resource_id} and \code{resource_type}
#' you can pass in a list to this parameter. see examples
#' @param ... Additional options passed down to \code{\link[httr]{POST}}
#' @return logical, \code{TRUE} if successful
#' @examples \dontrun{
#' d <- droplet_create()
#' tag_resource(name = "stuffthings", resource_id = d$id,
#'   resource_type = "droplet")
#' tag_resource("stuffthings", resources = list(list(resource_id = d$id,
#'   resource_type = "droplet")))
#' }
tag_resource <- function(name, resource_id = NULL, resource_type = "droplet",
                         resources = NULL, ...) {

  if (!xor(!is.null(resource_id), !is.null(resources))) {
    stop("One of 'resource_id' or 'resources' must be non-NULL", call. = FALSE)
  }
  if (is.null(resources)) {
    body <- list(resources = list(list(resource_id = resource_id,
                                       resource_type = resource_type)))
  } else {
    body <- list(resources = resources)
  }
  do_POST(url = sprintf('tags/%s/resources', name), body = body,
          encode = "json", ...)
}

#' Untag a resource
#'
#' @export
#' @param name (character) Name of the tag
#' @param resource_id (integer) a droplet id
#' @param resource_type (character) only "droplet" for now. Default: "droplet"
#' @param resources (list) instead of \code{resource_id} and
#' \code{resource_type} you can pass in a list to this parameter. see examples
#' @param ... Additional options passed down to \code{\link[httr]{DELETE}}
#' @return logical, \code{TRUE} if successful
#' @examples \dontrun{
#' d <- droplet_create()
#' tag_resource(name = "stuffthings", resource_id = d$id,
#'   resource_type = "droplet")
#' ## same as this because only allowed resource type right now is "droplet"
#' # tag_resource(name = "stuffthings", resource_id = d$id)
#' tag_resource_delete(name = "stuffthings", resource_id = d$id,
#'   resource_type = "droplet")
#' }
tag_resource_delete <- function(name, resource_id = NULL,
  resource_type = "droplet", resources = NULL, ...) {

  if (!xor(!is.null(resource_id), !is.null(resources))) {
    stop("One of 'resource_id' or 'resources' must be non-NULL", call. = FALSE)
  }
  if (is.null(resources)) {
    body <- list(resources = list(list(resource_id = resource_id,
                                       resource_type = resource_type)))
  } else {
    body <- list(resources = resources)
  }
  do_DELETE_body(url = sprintf('tags/%s/resources', name), body = body,
                 encode = "json", ...)
}

#' Perform actions on one or more droplets associated with a tag
#'
#' @export
#' @param name (character) Name of the tag. Required.
#' @param type (character) action type, one of 'power_cycle', 'power_on',
#' 'power_off', 'shutdown', 'enable_private_networking', 'enable_ipv6',
#' 'enable_backups', 'disable_backups', or 'snapshot'. Required.
#' @param ... Additional options passed down to \code{\link[httr]{POST}}
#' @examples \dontrun{
#' tag_create(name = "pluto")
#' d <- droplet_create()
#' tag_resource(name = "pluto", resource_id = d$id)
#' (x <- droplet_do_actions(name = "pluto", type = "power_off"))
#' # wait until completed, check with action(xx$actions[[1]]$id)
#' droplet_do_actions(name = "pluto", type = "power_on")
#' }
droplet_do_actions <- function(name, type, ...) {
  res <- do_POST('droplets/actions', query = list(tag_name = name),
          body = list(type = type), encode = "json", ...)
  as.action(res)
}


#' List tags
#'
#' @export
#' @param x Object to coerce to a tag.
#' @param name (character) Name of the tag
#' @param ... Additional options passed down to \code{\link[httr]{GET}}
#' @rdname tags
#' @return Many tag objects in a list
#' @details \code{tags} gets all your tag, \code{tag} gets a tag by name
#' @examples \dontrun{
#' # get all your tags
#' tags()
#'
#' # get a tag by name
#' tag("stuffthings")
#' tag("helloworld")
#' }
tags <- function(...) {
  as.tag(do_GET(url = 'tags', ...))
}

#' @export
#' @rdname tags
tag <- function(name, ...) {
  as.tag(do_GET(url = paste0('tags/', name), ...))
}

#' @export
#' @examples \dontrun{
#' tag_create("pluto")
#' as.tag('pluto')
#' as.tag(tag_create("howdyhoneighbor"))
#' }
#' @rdname tags
as.tag <- function(x) UseMethod("as.tag")
#' @export
as.tag.tag <- function(x) x
#' @export
as.tag.list <- function(x) list_to_object(x, "tag")
#' @export
as.tag.character <- function(x) tags()[[x]]

#' @export
print.tag <- function(x, ...) {
  cat("<tag> ", x$name, "\n", sep = "")
  cat("  Droplets (n): ", x$resources$droplets$count, "\n", sep = "")
  cat("  Last tagged droplet: ", x$resources$droplets$last_tagged$id,
      "\n", sep = "")
}
