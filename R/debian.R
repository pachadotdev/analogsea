#' Helpers for managing an debian droplets.
#'
#' @param droplet A droplet, or object that can be coerced to a droplet
#'   by \code{\link{as.droplet}}.
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
debian_add_swap <- function(droplet) {
  droplet_ssh(droplet,
    "fallocate -l 4G /swapfile",
    "chmod 600 /swapfile",
    "mkswap /swapfile",
    "sudo swapon /swapfile"
  )
}

#' @rdname debian
#' @export
debian_install_r <- function(droplet) {
  droplet %>%
    debian_apt_get_install("r-base", "r-base-dev") %>%
    droplet_ssh('echo "options(repos=c(\'http://cran.rstudio.com/\'))" > .Rprofile')
}

#' @rdname debian
#' @param user Default username for Rstudio.
#' @param password Default password for Rstudio.
#' @param version Version of rstudio to install.
#' @export
debian_install_rstudio <- function(droplet, user = "rstudio", password = "rstudio",
                                   version = "0.99.484") {
  droplet %>%
    debian_apt_get_install("gdebi-core", "libapparmor1") %>%
    droplet_ssh(
      sprintf('wget http://download2.rstudio.org/rstudio-server-%s-amd64.deb', version),
      sprintf("sudo gdebi rstudio-server-%s-amd64.deb --non-interactive", version),
      sprintf('adduser %s --disabled-password --gecos ""', user),
      sprintf('echo "%s:%s" | chpasswd', user, password)
    )
}

#' @rdname debian
#' @export
debian_install_shiny <- function(droplet, version = "1.4.0.756") {
  droplet %>%
    debian_install_r() %>%
    install_r_package("shiny") %>%
    install_r_package("rmarkdown") %>%
    debian_apt_get_install("gdebi-core") %>%
    droplet_ssh(
      sprintf("wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-%s-amd64.deb", version),
      sprintf("sudo gdebi shiny-server-%s-amd64.deb --non-interactive", version)
    )
}

debian_install_opencpu <- function(droplet, version = "1.5") {
  droplet %>%
    droplet_ssh(
      paste0("sudo add-apt-repository ppa:opencpu/opencpu-", version),
      "sudo apt-get update",
      "sudo apt-get -q -y install opencpu",
      "sudo service opencpu start"
    )
}

# apt-get helpers --------------------------------------------------------------

#' @rdname debian
#' @export
debian_apt_get_update <- function(droplet) {
  droplet_ssh(droplet,
    "sudo apt-get update -qq",
    "sudo apt-get upgrade -y"
  )
}

#' @rdname debian
#' @export
#' @param ... Arguments to apt-get install.
debian_apt_get_install <- function(droplet, ...) {
  droplet_ssh(droplet,
    paste0("sudo apt-get install -y --force-yes ", paste(..., collapse = " "))
  )
}

# r helpers --------------------------------------------------------------------

#' @rdname debian
#' @export
#' @param package Name of R package to install.
#' @param repo CRAN mirror to use.
install_r_package <- function(droplet, package, repo = "http://cran.rstudio.com") {
  droplet_ssh(droplet,
    sprintf("Rscript -e \"install.packages(\'%s\', repos=\'%s/\')\"", package, repo)
  )
}
