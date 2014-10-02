#' Execute R code on a droplet.
#'
#' Assumes that the droplet has R installed.
#'
#' @param droplet A droplet, or object that can be coerced to a droplet
#'   by \code{\link{as.droplet}}.
#' @param code Code to excute on Digital Ocean droplet.
#' @param verbose (logical) Print messages
#' @examples \donttest{
#' d <- droplet_new() %>% 
#'   debian_add_swap() %>%
#'   debian_install_r()
#' 
#' results <- d %>% droplet_execute({
#'   x <- letters
#'   numbers <- runif(1000)
#' })
#' 
#' droplet_delete(d)
#' }
droplet_execute <- function(droplet, code, verbose=TRUE, savepath=NULL) {
  browser()
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
  tmp <- tempfile()
  droplet_download(droplet, ".Rdata", tmp)
  
  e <- new.env(parent = emptyenv())
  load(tmp, envir = e)
  
  as.list(e)
}
