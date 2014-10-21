#' Remotely execute ssh code, upload & download files.
#' 
#' Assumes that you have ssh & scp installed, and password-less login set up
#' on the droplet.
#' 
#' @param droplet A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param ... Shell commands to run. Multiple commands are combined with
#'   \code{&&} so that execution will halt after the first failure.
#' @param user User name. Defaults to "root".
#' @param local,remote Local and remote paths.
#' @param verbose If TRUE, will print command before executing it.
#' @return On success, the droplet (invisibly). On failure, throws an 
#'   error.
#' @examples
#' \dontrun{
#' d <- droplet_create() %>% droplet_wait()
#' 
#' # Upgrade system packages
#' d %>% 
#'   droplet_ssh("apt-get update") %>% 
#'   droplet_ssh("sudo apt-get upgrade -y --force-yes") %>%
#'   droplet_ssh("apt-get autoremove -y") 
#'   
#' # Install R
#' d %>%
#'   droplet_ssh("apt-get install r-base-core r-base-dev --yes --force-yes")
#'   
#' # Upload and download files -------------------------------------------------
#'    
#' tmp <- tempfile()
#' saveRDS(mtcars, tmp)
#' d %>% droplet_upload(tmp, "mtcars.rds")
#' 
#' tmp2 <- tempfile()
#' d %>% droplet_download("mtcars.rds", tmp2)
#' mtcars2 <- readRDS(tmp2)
#' 
#' stopifnot(all.equal(mtcars, mtcars2))
#' }
#' @export
droplet_ssh <- function(droplet, ..., user = "root", verbose = FALSE) {
  droplet <- as.droplet(droplet)  
  
  lines <- paste(c(...), collapse = " \\\n&& ")
  cmd <- paste0(
    "ssh ", ssh_options(), 
    " ", user, "@", droplet_ip(droplet), 
    " ", shQuote(lines)
  )
  do_system(droplet, cmd, verbose = verbose)
}

ssh_options <- function() {
  opts <- c(
    BatchMode = "yes",
    StrictHostKeyChecking = "no",
    UserKnownHostsFile = file.path(tempdir(), "hosts")
  )
  paste0("-o ", names(opts), "=", opts, collapse = " ")
}

#' @export
#' @rdname droplet_ssh
droplet_upload <- function(droplet, local, remote, user = "root", verbose = FALSE) {
  droplet <- as.droplet(droplet)  

  cmd <- paste0(
    "scp ", ssh_options(), 
    " ", local,
    " ", user, "@", droplet_ip(droplet), ":", remote
  )
  
  do_system(droplet, cmd, verbose = verbose)  
}

#' @export
#' @rdname droplet_ssh
droplet_download <- function(droplet, remote, local, user = "root", verbose = FALSE) {
  droplet <- as.droplet(droplet)  
  
  cmd <- paste0(
    "scp ", ssh_options(), 
    " ", user, "@", droplet_ip(droplet), ":", remote, 
    " ", local
  )
  
  do_system(droplet, cmd, verbose = verbose)  
}


droplet_ip <- function(x) {
  v4 <- x$network$v4
  if (length(v4) == 0) {
    stop("No network interface registered for this droplet",
      call. = FALSE)
  }
  
  v4[[1]]$ip_address
}


do_system <- function(droplet, cmd, verbose = FALSE) {
  cli_tools()
  mssg(verbose, cmd)
  status <- system(cmd)
  if (status != 0) {
    stop("ssh failed\n", cmd, call. = FALSE)
  }
  
  invisible(droplet)  
}
