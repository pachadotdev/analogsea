#' Helpers for managing a ubuntu droplets.
#'
#' @param droplet A droplet, or object that can be coerced to a droplet
#'   by \code{\link{as.droplet}}.
#' @param user User name. Defaults to "root".
#' @param keyfile Optional private key file.
#' @param ssh_user (character) User account for ssh commands against droplet.
#' @param ssh_passwd Optional passphrase or callback function for authentication.
#'   Refer to the \code{ssh::ssh_connect} documentation for more
#'   details.
#' @param verbose If TRUE, will print command before executing it.
#' @param rprofile A character string that will be added to the .Rprofile
#' @name ubuntu
#' @examples
#' \dontrun{
#' d <- droplet_create()
#' d %>% ubuntu_add_swap()
#' d %>% ubuntu_apt_get_update()
#'
#' d %>% ubuntu_install_r()
#' d %>% ubuntu_install_rstudio()
#'
#' # Install libcurl, then build RCurl from source
#' d %>% ubuntu_apt_get_install("libcurl4-openssl-dev")
#' d %>% install_r_package("RCurl")
#' droplet_delete(d)
#' }
NULL

#' @rdname ubuntu
#' @export
ubuntu_add_swap <- function(droplet,
                            user = "root",
                            keyfile = NULL,
                            ssh_passwd = NULL,
                            verbose = FALSE
                            ) {
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

#' @rdname ubuntu
#' @export
ubuntu_install_r <- function(droplet,
                             user = "root",
                             keyfile = NULL,
                             ssh_passwd = NULL,
                             verbose = FALSE,
                             rprofile = "options(repos=c('CRAN'='https://cloud.r-project.org/'))"
                             ) {
  droplet %>%
    ubuntu_apt_get_cran(user = user,
                 keyfile = keyfile,
                 ssh_passwd = ssh_passwd,
                 verbose = verbose
    ) %>%
    ubuntu_apt_get_update(user = user,
                   keyfile = keyfile,
                   ssh_passwd = ssh_passwd,
                   verbose = verbose
    ) %>%
    ubuntu_apt_get_install("r-base", "r-base-dev",
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

#' @rdname ubuntu
#' @param user Default username for Rstudio.
#' @param password Default password for Rstudio.
#' @param version Version of rstudio to install.
#' @export
ubuntu_install_rstudio <- function(droplet, user = "rstudio", password = "server",
                                   version = "0.99.484",
                                   keyfile = NULL,
                                   ssh_passwd = NULL,
                                   verbose = FALSE
                                   ) {
  droplet %>%
    ubuntu_apt_get_install("gdebi-core", "libapparmor1",
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

#' @rdname ubuntu
#' @export
ubuntu_install_shiny <- function(droplet, version = "1.4.0.756",
                                 user = "root",
                                 keyfile = NULL,
                                 ssh_passwd = NULL,
                                 verbose = FALSE,
                                 rprofile = "options(repos=c('CRAN'='https://cloud.r-project.org/'))"
                                 ) {
  droplet %>%
    ubuntu_install_r(
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
    ubuntu_apt_get_install("gdebi-core",
                           user = user,
                           keyfile = keyfile,
                           ssh_passwd = ssh_passwd,
                           verbose = verbose
                           ) %>%
    droplet_ssh(
      sprintf("wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-%s-amd64.deb", version),
      sprintf("sudo gdebi shiny-server-%s-amd64.deb --non-interactive", version),
      user = user,
      keyfile = keyfile,
      ssh_passwd = ssh_passwd,
      verbose = verbose
    )
}

ubuntu_install_opencpu <- function(droplet, version = "1.5",
                                   user = "root",
                                   keyfile = NULL,
                                   ssh_passwd = NULL,
                                   verbose = FALSE
                                   ) {
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

#' @rdname ubuntu
#' @export
ubuntu_apt_get_cran <- function(droplet,
                         user = "root",
                         keyfile = NULL,
                         ssh_passwd = NULL,
                         verbose = FALSE) {
  version <- droplet$image$name
  cran_key <- if(any(version %in% c("20.04 (LTS) x64", "18.04 (LTS) x64"))) {
    "E298A3A825C0D65DFD57CBB651716619E084DAB9"
  }
  if (is.null(cran_key)) {
    message("The CRAN setup requires to use the ubuntu-20-04-x64 or ubuntu-18-04-x64 images.")
    stop()
  }
  cran_url <- "https://cran.pacha.dev/bin/linux/ubuntu/"
  cran_apt <- switch(
    version,
    "20.04 (LTS) x64" = "focal-cran40",
    "18.04 (LTS) x64" = "bionic-cran35"
  )
  droplet_ssh(droplet,
              sprintf(
                "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys %s", cran_key
              ),
              sprintf(
                "printf '\n#CRAN mirror\n deb %s %s/\n' | sudo tee -a /etc/apt/sources.list", cran_url, cran_apt
              ),
              user = user,
              keyfile = keyfile,
              ssh_passwd = ssh_passwd,
              verbose = verbose
  )
}

#' @rdname ubuntu
#' @export
ubuntu_apt_get_update <- function(droplet,
                                  user = "root",
                                  keyfile = NULL,
                                  ssh_passwd = NULL,
                                  verbose = FALSE) {
  droplet_ssh(droplet,
              "sudo apt-get update -qq",
              "sudo apt-get upgrade -y",
              user = user,
              keyfile = keyfile,
              ssh_passwd = ssh_passwd,
              verbose = verbose
  )
}

#' @rdname ubuntu
#' @export
#' @param ... Arguments to apt-get install.
ubuntu_apt_get_install <- function(droplet, ...,
                                   user = "root",
                                   keyfile = NULL,
                                   ssh_passwd = NULL,
                                   verbose = FALSE) {
  droplet_ssh(droplet,
              paste0("sudo apt-get install -y --force-yes ", paste(..., collapse = " ")),
              user = user,
              keyfile = keyfile,
              ssh_passwd = ssh_passwd,
              verbose = verbose
  )
}

# r helpers --------------------------------------------------------------------

#' @rdname ubuntu
#' @export
#' @param package Name of R package to install.
#' @param repo CRAN mirror to use.
install_r_package <- function(droplet, package, repo = "https://cloud.r-project.org/",
                              user = "root",
                              keyfile = NULL,
                              ssh_passwd = NULL,
                              verbose = FALSE
) {
  droplet_ssh(droplet,
              sprintf("Rscript -e \"install.packages(\'%s\', repos=\'%s/\')\"",
                      package, repo),
              user = user,
              keyfile = keyfile,
              ssh_passwd = ssh_passwd,
              verbose = verbose
  )
}

#' @rdname ubuntu
#' @export
#' @param package Name of R package to install.
#' @param repo CRAN mirror to use.
install_github_r_package <- function(droplet, package,
                                     repo = "https://cloud.r-project.org/",
                                     user = "root",
                                     keyfile = NULL,
                                     ssh_passwd = NULL,
                                     verbose = FALSE
) {
  tf <- tempdir()
  randName <- paste(sample(c(letters, LETTERS), size = 10,
                           replace = TRUE), collapse = "")
  tff <- file.path(tf, randName)
  on.exit({
    if (file.exists(tff)) {
      file.remove(tff)
    }
  })
  command = "Rscript -e \"cat(requireNamespace('remotes', quietly = TRUE))\""
  droplet_ssh(droplet,
              paste0(command,
                     " > /tmp/",
                     randName),
              user = user,
              keyfile = keyfile,
              ssh_passwd = ssh_passwd,
              verbose = verbose
  )
  droplet_download(droplet,
                   paste0("/tmp/", randName),
                   tf,
                   user = user,
                   keyfile = keyfile,
                   ssh_passwd = ssh_passwd,
                   verbose = verbose)
  droplet_ssh(droplet, paste0("rm /tmp/", randName),
              user = user,
              keyfile = keyfile,
              ssh_passwd = ssh_passwd,
              verbose = verbose)

  have_remotes <- readLines(tff, warn = FALSE)
  if (length(have_remotes) == 1) {
    if (have_remotes %in% c("TRUE", "FALSE")) {
      have_remotes = as.logical(have_remotes)
    } else {
      have_remotes = FALSE
    }
  } else {
    have_remotes = FALSE
  }
  if (!have_remotes) {
    install_r_package(droplet, "remotes", repo = repo,
                      user = user,
                      keyfile = keyfile,
                      ssh_passwd = ssh_passwd,
                      verbose = verbose
    )
  }

  droplet_ssh(
    droplet,
    sprintf("Rscript -e \"remotes::install_github('%s')\"",
            package),
    user = user,
    keyfile = keyfile,
    ssh_passwd = ssh_passwd,
    verbose = verbose
  )
}

# add users ----

#' Create a password with digits, letters and special characters
#' @param n Password length (8-15 characters)
#' @examples create_password(10)
#' @export
create_password <- function(n = 8) {
  stopifnot(n >= 8 & n <= 15)
  stopifnot(length(n) == 1 & is.numeric(n))

  sam <- list()
  sam[[1]] <- 0:9
  sam[[2]] <- letters
  sam[[3]] <- LETTERS

  p <- mapply(sample, sam, 10)
  return(paste(sample(p, n), collapse = ""))
}

#' @rdname ubuntu
#' @param user Username for non-root account.
#' @param password Password for non-root acount. Default: root
#' @export
create_user <- function(droplet, user, password,
                        ssh_user = "root", keyfile = NULL,
                        ssh_passwd = NULL, verbose = FALSE) {
  check_for_a_pkg("ssh")
  if (missing(user)) stop("'user' is required")
  if (missing(password)) {
    password <- create_password(10)
    warning(sprintf("no 'password' suplied for '%s', using '%s'", user, password))
  }
  if (password == "rstudio") stop("supply a 'password' other than 'rstudio'")
  droplet <- as.droplet(droplet)

  droplet_ssh(droplet,
              sprintf(
                "useradd -m -p $(openssl passwd -1 %s) %s", password, user
              ),
              user = ssh_user,
              keyfile = keyfile,
              ssh_passwd = ssh_passwd,
              verbose = verbose
  )
}
