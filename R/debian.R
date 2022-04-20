#' Helpers for managing a debian droplets.
#'
#' @param droplet A droplet, or object that can be coerced to a droplet
#'   by \code{\link{as.droplet}}.
#' @param user User name. Defaults to "root".
#' @param keyfile Optional private key file.
#' @param ssh_passwd Optional passphrase or callback function for authentication.
#'   Refer to the \code{ssh::ssh_connect} documentation for more
#'   details.
#' @param verbose If TRUE, will print command before executing it.
#' @param rprofile A character string that will be added to the .Rprofile
#' @name debian
#' @examples
#' \dontrun{
#' d <- droplet_create()
#' d %>% debian_add_swap()
#' d %>% debian_apt_get_update()
#'
#' d %>% debian_install_r()
#' d %>% debian_install_rstudio()
#'
#' # Install libcurl, then build RCurl from source
#' d %>% debian_apt_get_install("libcurl4-openssl-dev")
#' d %>% install_r_package("RCurl")
#' droplet_delete(d)
#' }
NULL

#' @rdname debian
#' @export
debian_add_swap <- function(droplet,
                            user = "root",
                            keyfile = NULL,
                            ssh_passwd = NULL,
                            verbose = FALSE
) {
  .Deprecated("ubuntu_add_swap")

  droplet_ssh(droplet,
              "fallocate -l 4G /swapfile",
              "chmod 600 /swapfile",
              "mkswap /swapfile",
              "sudo swapon /swapfile",
              "sudo echo \"/swapfile   none    swap    sw    0   0\" >> /etc/fstab",
              user = user,
              keyfile = keyfile,
              ssh_passwd = ssh_passwd,
              verbose = verbose
  )
}

#' @rdname debian
#' @export
debian_install_r <- function(droplet,
                             user = "root",
                             keyfile = NULL,
                             ssh_passwd = NULL,
                             verbose = FALSE,
                             rprofile = "options(repos=c('CRAN'='https://cloud.r-project.org/'))"
) {
  .Deprecated("ubuntu_install_r")

  droplet %>%
    debian_apt_get_install("r-base", "r-base-dev",
                           user = user,
                           keyfile = keyfile,
                           ssh_passwd = ssh_passwd,
                           verbose = verbose
    ) %>%
    droplet_ssh(paste("echo", shQuote(rprofile), "> .Rprofile"),
                user = user,
                keyfile = keyfile,
                ssh_passwd = ssh_passwd,
                verbose = verbose
    )
}

#' @rdname debian
#' @param user Default username for Rstudio.
#' @param password Default password for Rstudio.
#' @param version Version of rstudio to install.
#' @export
debian_install_rstudio <- function(droplet, user = "rstudio", password = "server",
                                   version = "0.99.484",
                                   keyfile = NULL,
                                   ssh_passwd = NULL,
                                   verbose = FALSE
) {
  .Deprecated("ubuntu_install_rstudio")

  droplet %>%
    debian_apt_get_install("gdebi-core", "libapparmor1",
                           user = user,
                           keyfile = keyfile,
                           ssh_passwd = ssh_passwd,
                           verbose = verbose
    ) %>%
    droplet_ssh(
      sprintf('wget http://download2.rstudio.org/rstudio-server-%s-amd64.deb', version),
      sprintf("sudo gdebi rstudio-server-%s-amd64.deb --non-interactive", version),
      sprintf('adduser %s --disabled-password --gecos ""', user),
      sprintf('echo "%s:%s" | chpasswd', user, password),
      user = user,
      keyfile = keyfile,
      ssh_passwd = ssh_passwd,
      verbose = verbose
    )
}

#' @rdname debian
#' @export
debian_install_shiny <- function(droplet, version = "1.4.0.756",
                                 user = "root",
                                 keyfile = NULL,
                                 ssh_passwd = NULL,
                                 verbose = FALSE,
                                 rprofile = "options(repos=c('CRAN'='https://cloud.r-project.org/'))"
) {
  .Deprecated("ubuntu_install_shiny")

  droplet %>%
    debian_install_r(
      user = user,
      keyfile = keyfile,
      ssh_passwd = ssh_passwd,
      verbose = verbose,
      rprofile = rprofile
    ) %>%
    install_r_package("shiny",
                      user = user,
                      keyfile = keyfile,
                      ssh_passwd = ssh_passwd,
                      verbose = verbose
    ) %>%
    install_r_package("rmarkdown",
                      user = user,
                      keyfile = keyfile,
                      ssh_passwd = ssh_passwd,
                      verbose = verbose
    ) %>%
    debian_apt_get_install("gdebi-core",
                           user = user,
                           keyfile = keyfile,
                           ssh_passwd = ssh_passwd,
                           verbose = verbose
    ) %>%
    droplet_ssh(
      sprintf("wget http://download3.rstudio.org/debian-12.04/x86_64/shiny-server-%s-amd64.deb", version),
      sprintf("sudo gdebi shiny-server-%s-amd64.deb --non-interactive", version),
      user = user,
      keyfile = keyfile,
      ssh_passwd = ssh_passwd,
      verbose = verbose
    )
}

debian_install_opencpu <- function(droplet, version = "1.5",
                                   user = "root",
                                   keyfile = NULL,
                                   ssh_passwd = NULL,
                                   verbose = FALSE
) {
  .Deprecated("ubuntu_install_opencpu")

  droplet %>%
    droplet_ssh(
      paste0("sudo add-apt-repository ppa:opencpu/opencpu-", version),
      "sudo apt-get update",
      "sudo apt-get -q -y install opencpu",
      "sudo service opencpu start",
      user = user,
      keyfile = keyfile,
      ssh_passwd = ssh_passwd,
      verbose = verbose
    )
}

# apt-get helpers --------------------------------------------------------------

#' @rdname debian
#' @export
debian_apt_get_update <- function(droplet,
                                  user = "root",
                                  keyfile = NULL,
                                  ssh_passwd = NULL,
                                  verbose = FALSE) {
  .Deprecated("ubuntu_apt_get_update")

  droplet_ssh(droplet,
              "sudo apt-get update -qq",
              "sudo apt-get upgrade -y",
              user = user,
              keyfile = keyfile,
              ssh_passwd = ssh_passwd,
              verbose = verbose
  )
}

#' @rdname debian
#' @export
#' @param ... Arguments to apt-get install.
debian_apt_get_install <- function(droplet, ...,
                                   user = "root",
                                   keyfile = NULL,
                                   ssh_passwd = NULL,
                                   verbose = FALSE) {
  .Deprecated("debian_apt_get_install")

  droplet_ssh(droplet,
              paste0("sudo apt-get install -y --force-yes ", paste(..., collapse = " ")),
              user = user,
              keyfile = keyfile,
              ssh_passwd = ssh_passwd,
              verbose = verbose
  )
}
