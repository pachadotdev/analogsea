project_url <- function(project = NULL) {
  if (is.null(project)) url("projects") else url("projects", project)
}

#' @param x Object to coerce to a project.
#' @export
#' @rdname projects
as.project <- function(x) UseMethod("as.project")
#' @export
as.project.list <- function(x) list_to_object(x, "project")
#' @export
as.project.project <- function(x) x
#' @export
as.project.numeric <- function(x) project(x)
#' @export
as.project.character <- function(x) projects()[[x]]

#' Get list of projects and their metadata, or a single project
#'
#' @export
#' @param id (character) project id, default: "default"
#' @inheritParams droplets
#' @examples \dontrun{
#' projects()
#' project("f9597f51-6fb0-492c-866d-bc67bff6d409")
#' }
projects <- function(page = NULL, per_page = NULL, ...) {
  res <- do_GET(project_url(),
    query = ascompact(list(page = page, per_page = per_page)), 
    httr::content_type_json(), ...)
  as.project(res)
}

#' @export
#' @rdname projects
project <- function(id = "default", ...) {
  res <- do_GET(project_url(id), ...)
  as.project(res)
}

#' @export
print.project <- function(x, ...) {
  cat("<project> ", x$name, " (", x$id, ")", "\n", sep = "")
  cat("  Description: ", x$description, "\n", sep = "")
  cat("  Default?: ", x$is_default, "\n", sep = "")
}

#' @export
as.url.project <- function(x, ...) {
  project_url(x$id)
}

#' Delete a project
#'
#' @export
#' @param project A project to modify.
#' @param ... Options passed on to httr::GET. Must be named, see examples.
#' @examples \dontrun{
#' project_delete(5620385)
#' }
project_delete <- function(project, ...) {
  project <- as.project(project)
  do_DELETE(project, ...)
}

#' Create a project
#'
#' @export
#' @param name (character) Name of the project. required
#' @param purpose (character) The purpose of the project. The maximum length
#' is 255 characters. For examples of valid purposes, see the "Purposes"
#' section. required
#' @param description (character) The description of the project. The maximum
#' length is 255 characters. optional
#' @param environment (character) The environment of the project's resources.
#' optional
#' @param ... Additional options passed down to \code{\link[httr]{POST}}
#' @return A project object
#' @section Purposes:
#' The purpose attribute can have one of the following values:
#' 
#' - Just trying out DigitalOcean
#' - Class project / Educational purposes
#' - Website or blog
#' - Web Application
#' - Service or API
#' - Mobile Application
#' - Machine learning / AI / Data processing
#' - IoT
#' - Operational / Developer tooling
#' 
#' If specify another value for purpose, for example "your custom purpose",
#' your purpose will be stored as Other: your custom purpose
#' 
#' @section Environments:
#' The environment attribute must have one of the following values:
#' 
#' - Development
#' - Staging
#' - Production
#' 
#' If another value is specified, a 400 Bad Request is returned.
#' 
#' @examples \dontrun{
#' project_create(name = "venus", purpose = "Web Application")
#' }
project_create <- function(name, purpose, description = NULL,
  environment = NULL, ...) {
  
  as.project(
    do_POST(url = 'projects', body = ascompact(list(name = name,
      purpose = purpose, description = description,
      environment = environment)), ...)
  )
}

#' Update all aspects of a project
#'
#' @export
#' @inheritParams project_create
#' @param id project id. to update the default project use "default". required
#' @param is_default (logical) If `TRUE`, all resources will be added to this
#' project if no project is specified. default: `FALSE`
project_update <- function(id, name, purpose, description, is_default = FALSE,
  environment = NULL, ...) {
  
  as.project(
    do_PUT(url = file.path('projects', id), body = ascompact(list(name = name,
      purpose = purpose, description = description,
      environment = environment, is_default = is_default)), ...)
  )
}

#' Update certain aspects of a project
#' @export
#' @inheritParams project_update
project_patch <- function(id, name = NULL, purpose = NULL, description = NULL,
  is_default = FALSE, environment = NULL, ...) {
  
  as.project(
    do_PATCH(url = file.path('projects', id), body = ascompact(list(name = name,
      purpose = purpose, description = description,
      environment = environment, is_default = is_default)), ...)
  )
}
