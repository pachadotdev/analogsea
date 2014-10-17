#' Remotely execute ssh code, upload & download files.
#' 
#' Assumes that you have ssh & scp installed, and password-less login set up
#' on the droplet.  Use \code{droplet_reset_host} to reset your host file 
#' if you get complaints from ssh - this usually occurs when you have a new
#' droplet on a previously used ip address.
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
  cmd <- sprintf("ssh -o BatchMode=yes -o StrictHostKeyChecking=no %s@%s %s", user, 
    droplet_ip(droplet), shQuote(lines))
  do_system(droplet, cmd, verbose = verbose)
}

#' @export
#' @rdname droplet_ssh
droplet_upload <- function(droplet, local, remote, user = "root", verbose = FALSE) {
  droplet <- as.droplet(droplet)  
  
  cmd <- sprintf("scp -o StrictHostKeyChecking=no %s %s@%s:~/%s", 
    local, user, droplet_ip(droplet), remote)
  do_system(droplet, cmd, verbose = verbose)  
}

#' @export
#' @rdname droplet_ssh
droplet_download <- function(droplet, remote, local, user = "root", verbose = FALSE) {
  droplet <- as.droplet(droplet)  
  
  cmd <- sprintf("scp -o StrictHostKeyChecking=no %s@%s:~/%s %s", 
    user, droplet_ip(droplet), remote, local)
  do_system(droplet, cmd, verbose = verbose)  
}


#' @export 
#' @rdname droplet_ssh
droplet_reset_host <- function(droplet) {
  droplet <- as.droplet(droplet)  
  system(paste0("ssh-keygen -R ", droplet_ip(droplet)))
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
  mssg(verbose, cmd)
  status <- system(cmd)
  if (status != 0) {
    stop("ssh failed\n", cmd, call. = FALSE)
  }
  
  invisible(droplet)  
}
