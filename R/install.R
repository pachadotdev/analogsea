add_swap <- function(droplet) {
  droplet_ssh(droplet, 
    "sudo fallocate -l 4G /swapfile",
    "sudo chmod 600 /swapfile",
    "sudo mkswap /swapfile",
    "sudo swapon /swapfile"
  )
}

install_r <- function(droplet) {
  droplet %>%
    apt_get_install("r-base", "r-base-dev") %>%
    droplet_ssh('echo "options(repos=c(\'http://cran.rstudio.com/\'))" > .Rprofile')
}


install_rstudio <- function(droplet, user = "rstudio", password = "rstudio", 
                            version = "0.98.1062") {
  droplet %>%
    apt_get_install("gdebi-core", "libapparmor1") %>%
    droplet_ssh(
      sprintf('wget http://download2.rstudio.org/rstudio-server-%s-amd64.deb', version),
      sprintf("sudo gdebi rstudio-server-%s-amd64.deb --non-interactive", version),
      sprintf('adduser %s --disabled-password --gecos ""', user),
      sprintf('echo "%s:%s" | chpasswd', user, password)
    )   
}

install_shiny <- function(droplet) {
  droplet %>%
    install_r() %>%
    install_r_package("shiny") %>%
    install_r_package("rmarkdown") %>%
    apt_get_install("gdebi-core") %>%
    droplet_ssh(
      "wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-%s-amd64.deb",
      "sudo gdebi shiny-server-%s-amd64.deb --non-interactive"
    )
}


install_opencpu <- function(droplet) {
  droplet %>%
    droplet_ssh(
      "sudo add-apt-repository ppa:opencpu/opencpu-1.4",
      "sudo apt-get update",
      "sudo apt-get -q -y install opencpu",
      "sudo service opencpu start"
    )
}

# apt-get helpers --------------------------------------------------------------

apt_get_update <- function(droplet) {
  droplet_ssh(droplet, 
    "sudo apt-get update -qq",
    "sudo apt-get upgrade -y"
  )
}
apt_get_install <- function(droplet, ...) {
  droplet_ssh(droplet, 
    paste0("sudo apt-get install -y --force-yes ", paste(..., collapse = " "))
  )
}

# r helpers --------------------------------------------------------------------

install_r_package <- function(droplet, package, repo = "http://cran.rstudio.com") {
  sprintf("R -e \\\"install.packages(\'%s\', repos=\'%s/\')\\\"", package)
}
