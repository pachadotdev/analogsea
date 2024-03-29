#' Execute R code on a droplet.
#'
#' @export
#' @param droplet A droplet, or object that can be coerced to a droplet
#'   by \code{\link{as.droplet}}.
#' @param code Code to execute on a droplet.
#' @param verbose (logical) Print messages. Default: \code{TRUE}
#' @details Assumes that the droplet has R installed.
#' @examples \dontrun{
#' d <- droplet_create() %>%
#'   ubuntu_add_swap() %>%
#'   droplet_ssh("apt-get update") %>%
#'   ubuntu_install_r()
#'
#' results <- d %>% droplet_execute({
#'   x <- letters
#'   numbers <- runif(1000)
#' })
#' results$x
#' results$numbers
#'
#' droplet_delete(d)
#' }
droplet_execute <- function(droplet, code, verbose=TRUE) {
  check_for_a_pkg("ssh")
  droplet <- as.droplet(droplet)
  code <- substitute(code)
  # Remove surrounding `{`
  if (identical(code[[1]], quote(`{`))) {
    code <- as.list(code[-1])
  } else {
    code <- list(code)
  }
  text <- unlist(lapply(code, deparse))

  mssg(verbose, "Uploading R code to droplet...")
  tmp <- tempfile()
  writeLines(text, tmp)
  droplet_upload(droplet, tmp, "remote.R")

  mssg(verbose, "Running R code...")
  droplet_ssh(droplet, "Rscript --save remote.R")

  mssg(verbose, "Downloading results...")
  tmp <- tempdir()
  droplet_download(droplet, ".RData", tmp)

  e <- new.env(parent = emptyenv())
  load(file.path(tmp, ".RData"), envir = e)

  as.list(e)
}
