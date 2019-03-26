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
#' @param keyfile Optional private key file.
#' @param ssh_passwd Optional passphrase or callback function for authentication.
#'   Refer to the \code{\link[ssh]{ssh_connect}} documentation for more
#'   details.
#' @param verbose If TRUE, will print command before executing it.
#' @param overwrite If TRUE, then overwrite destination files if they already
#'   exist.
#' @details With the chang to package \pkg{ssh}, we create ssh session objects
#' (C pointers) internally, and cache them, then look them up in the cache
#' based on combination of user and IP address. That is, there's separate
#' sessions for each user for the same IP address.
#'
#' ssh sessions are cleaned up at the end of your R session.
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
#' d %>% droplet_upload(tmp, ".")
#' d %>% droplet_ssh("ls")
#'
#' tmp2 <- tempdir()
#' d %>% droplet_download(basename(tmp), tmp2)
#' mtcars2 <- readRDS(file.path(tmp2, basename(tmp)))
#'
#' stopifnot(all.equal(mtcars, mtcars2))
#'
#'
#' ## another upload/download example
#' tmp <- tempfile(fileext = ".txt")
#' writeLines("foo bar", tmp)
#' readLines(tmp)
#' d %>% droplet_upload(tmp, ".")
#' d %>% droplet_ssh("ls")
#'
#' tmp2 <- tempdir()
#' unlink(tmp)
#' d %>% droplet_download(basename(tmp), tmp2)
#' readLines(file.path(tmp2, basename(tmp)))
#' }
#' @export
droplet_ssh <- function(droplet, ..., user = "root", keyfile = NULL, ssh_passwd = NULL, verbose = FALSE) {
  droplet <- as.droplet(droplet)

  lines <- paste(c(...), collapse = " \\\n&& ")
  if (lines == "") stop("Provide commands", call. = FALSE)
  do_ssh(droplet, lines, user, keyfile = keyfile, ssh_passwd = ssh_passwd, verbose = verbose)
}

#' @export
#' @rdname droplet_ssh
droplet_upload <- function(droplet, local, remote, user = "root", keyfile = NULL, 
  ssh_passwd = NULL, verbose = FALSE) {

  droplet <- as.droplet(droplet)
  do_scp(droplet, local, remote, user, 
    keyfile = keyfile, ssh_passwd = ssh_passwd, 
    verbose = verbose)
}

#' @export
#' @rdname droplet_ssh
droplet_download <- function(droplet, remote, local, user = "root",
  keyfile = NULL, ssh_passwd = NULL, verbose = FALSE, overwrite = FALSE) {

  droplet <- as.droplet(droplet)
  do_scp(droplet, local, remote, user, scp = "download", 
    keyfile, ssh_passwd, verbose = verbose)
}


# helpers ---------------------
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

do_ssh <- function(droplet, cmd, user, keyfile = NULL, ssh_passwd = NULL, verbose = FALSE) {
  mssg(verbose, cmd)
  user_ip <- sprintf("%s@%s", user, droplet_ip_safe(droplet))
  if (user_ip %in% ls(envir = analogsea_sessions)) {
    session <- get(user_ip, envir = analogsea_sessions)
    if (!ssh::ssh_info(session=session)$connected) {
      session <- if (is.null(ssh_passwd)) {
        ssh::ssh_connect(user_ip, keyfile)
      } else {
        ssh::ssh_connect(user_ip, keyfile, ssh_passwd)
      }
      assign(user_ip, session, envir = analogsea_sessions)
    }
  } else {
    session <- if (is.null(ssh_passwd)) {
      ssh::ssh_connect(user_ip, keyfile)
    } else {
      ssh::ssh_connect(user_ip, keyfile, ssh_passwd)
    }
    assign(user_ip, session, envir = analogsea_sessions)
  }
  out <- ssh::ssh_exec_wait(session = session, command = cmd)
  if (out != 0) {
    stop("ssh failed\n", cmd, call. = FALSE)
  }

  invisible(droplet)
}

do_scp <- function(droplet, local, remote, user,
  scp = "upload", keyfile = NULL, ssh_passwd = NULL, verbose = FALSE) {

  user_ip <- sprintf("%s@%s", user, droplet_ip_safe(droplet))
  if (user_ip %in% ls(envir = analogsea_sessions)) {
    session <- get(user_ip, envir = analogsea_sessions)
  } else {
    session <- if (is.null(ssh_passwd)) {
      ssh::ssh_connect(user_ip, keyfile)
    } else {
      ssh::ssh_connect(user_ip, keyfile, ssh_passwd)
    }
    assign(user_ip, session, envir = analogsea_sessions)
  }
  if (scp == "upload") cat(ssh::scp_upload(session = session,
    files = local, to = remote, verbose = TRUE), sep = "\n")
  if (scp == "download") cat(ssh::scp_download(session = session,
    files = remote, to = local, verbose = TRUE), sep = "\n")
  invisible(droplet)
}
