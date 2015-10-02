#' Copy a local project to a docklet.
#'
#' Currently a work in progress.
#'
#' @param droplet A docklet, created with \code{\link{docklet_create}}.
#'   Must have docker installed.
#' @param project Path to a rstudio + packrat project.
#' @param user,password Default username and password for RStudio
#' @param verbose Print messages (default TRUE)
#' @keywords internal
#' @examples \dontrun{
#' d <- docklet_create()
#' d %>% docklet_packrat(".")
#' }
docklet_packrat <- function(droplet, project, user = 'rstudio',
                            password = 'rstudio', verbose = TRUE) {
  if (!requireNamespace("packrat", quietly = TRUE)) {
    stop("Please install packrat", call. = FALSE)
  }

  droplet <- as.droplet(droplet)

  if (!file.exists(project) || !file.info(project)$isdir) {
    stop("Project must exist and be a directory", call. = FALSE)
  }
  name <- dirname(project)

  mssg(verbose, "Bundling project and uploading...")
  bundle <- packrat::bundle(project, overwrite = TRUE)
  droplet_upload(droplet, bundle, paste0(name, ".tar.gz"))

  # Tell remote (server? container?) to unbundle
  mssg(verbose, "Unbundling and installing...")

  # Launch rstudio:
  # * Need to randomise port (or select unused)
  # * Need to attach volume
  # * Need to launch this project
  mssg(verbose, "Launching RStudio...")
  docklet_rstudio(droplet, user = user, password = password)
}
