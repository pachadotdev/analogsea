#' Remotely execute ssh code, upload & download files.
#'
#' Assumes that you have ssh & scp installed, and password-less login set up on
#' the droplet.
#'
#' Uploads and downloads are recursive, so if you specify a directory,
#' everything inside the directory will also be downloaded.
#'
#' @param droplet A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param ... Shell commands to run. Multiple commands are combined with
#'   \code{&&} so that execution will halt after the first failure.
#' @param user User name. Defaults to "root".
#' @param local,remote Local and remote paths.
#' @param verbose If TRUE, will print command before executing it.
#' @param overwrite If TRUE, then overwrite destination files if they already
#'   exist.
#' @return On success, the droplet (invisibly). On failure, throws an error.
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
#' d %>% droplet_upload(tmp, "mtcars2.rds")
#'
#' tmp2 <- tempdir()
#' d %>% droplet_download("mtcars2.rds", tmp2)
#' mtcars2 <- readRDS(tmp2)
#'
#' stopifnot(all.equal(mtcars, mtcars2))
#' }
#' @export
droplet_ssh <- function(droplet, ..., user = "root", verbose = FALSE) {
  droplet <- as.droplet(droplet)

  lines <- paste(c(...), collapse = " \\\n&& ")
  if (lines == "") stop("Provide commands", call. = FALSE)
  do_ssh(droplet, lines, user, verbose = verbose)
}

#' @export
#' @rdname droplet_ssh
droplet_upload <- function(droplet, local, remote, user = "root", verbose = FALSE) {
  droplet <- as.droplet(droplet)
  do_scp(droplet, local, remote, user, verbose = verbose)
}

#' @export
#' @rdname droplet_ssh
droplet_download <- function(droplet, remote, local, user = "root",
                             verbose = FALSE, overwrite = FALSE) {
  droplet <- as.droplet(droplet)

  # local <- normalizePath(local, mustWork = FALSE)

  # if (file.exists(local) && file.info(local)$isdir) {
  #   # If `local` exists and is a dir, then just put the result in that directory
  #   local_dir <- local
  #   need_rename <- FALSE

  # } else {
  #   # If `local` isn't an existing directory, put the result in the parent
  #   local_dir <- dirname(local)
  #   need_rename <- TRUE
  # }

  # # A temp dir for the downloaded file(s)
  # local_tempdir <- tempfile("download", local_dir)
  # local_tempfile <- file.path(local_tempdir, basename(remote))

  # if (need_rename) {
  #   # Rename to local name
  #   dest <- file.path(local_dir, basename(local))
  # } else {
  #   # Keep original name
  #   dest <- file.path(local_dir, basename(remote))
  # }

  # if (file.exists(dest) && !overwrite) {
  #   stop("Destination file already exists.")
  # }

  # dir.create(local_tempdir)

  # # Rename the downloaded files when we exit
  # on.exit({
  #   if (file.exists(dest)) unlink(dest, recursive = TRUE)
  #   file.rename(local_tempfile, dest)
  #   unlink(local_tempdir, recursive = TRUE)
  # })

  # This ssh's to the remote machine, tars the file(s), and sends it to the
  # local host where it is untarred.
  # cmd <- paste0(
  #   "ssh ", ssh_options(),
  #   " ", user, "@", droplet_ip(droplet), " ",
  #   sprintf("'cd %s && tar cz %s'", dirname(remote), basename(remote)),
  #   " | ",
  #   sprintf("(cd %s && tar xz)", local_tempdir)
  # )

  # do_ssh(droplet, cmd, user, verbose = verbose)
  do_scp(droplet, local, remote, user, scp = "download", verbose = verbose)
}


droplet_ip <- function(x) {
  v4 <- x$network$v4
  if (length(v4) == 0) {
    stop("No network interface registered for this droplet\n  Try refreshing like: droplet(d$id)",
      call. = FALSE)
  }

  v4[[1]]$ip_address
}


droplet_ip_safe <- function(x) {
  res <- tryCatch(droplet_ip(x), error = function(e) e)
  if (inherits(res, "simpleError")) 'droplet likely not up yet' else res
}

do_ssh <- function(droplet, cmd, user, verbose = FALSE) {
  mssg(verbose, cmd)
  user_ip <- sprintf("%s@%s", user, droplet_ip(droplet))
  # cat(user_ip, sep = "\n")
  if (user_ip %in% ls(envir = analogsea_sessions)) {
    # cat("session found", sep = "\n")
    session <- get(user_ip, envir = analogsea_sessions)
  } else {
    # cat("session not found, creating it now", sep = "\n")
    session <- ssh::ssh_connect(user_ip)
    assign(user_ip, session, envir = analogsea_sessions)
  }
  # cat("running ssh_exec_wait", sep = "\n")
  out <- ssh::ssh_exec_wait(session = session, command = cmd)
  # cat(rawToChar(out$stdout))
  if (out != 0) {
    stop("ssh failed\n", cmd, call. = FALSE)
  }

  invisible(droplet)
}

do_scp <- function(droplet, local, remote, user, 
  scp = "upload", verbose = FALSE) {

  # mssg(verbose, cmd)
  user_ip <- sprintf("%s@%s", user, droplet_ip(droplet))
  # cat(user_ip, sep = "\n")
  if (user_ip %in% ls(envir = analogsea_sessions)) {
    # cat("session found", sep = "\n")
    session <- get(user_ip, envir = analogsea_sessions)
  } else {
    # cat("session not found, creating it now", sep = "\n")
    session <- ssh::ssh_connect(user_ip)
    assign(user_ip, session, envir = analogsea_sessions)
  }
  # cat("running ssh_exec_wait", sep = "\n")
  if (scp == "upload") cat(ssh::scp_upload(session = session, 
    files = local, to = remote, verbose = TRUE), sep = "\n")
  if (scp == "download") cat(ssh::scp_download(session = session, 
    files = remote, to = local, verbose = TRUE), sep = "\n")
  invisible(droplet)
}
