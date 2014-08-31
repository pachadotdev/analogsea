#' Install RStudio on a Digital Ocean droplet
#'
#' @export
#' @param id A Digital Ocean droplet ID
#' @param usr Username to use to login - ignored if rstudio_server not installed
#' @param pwd Password to use to login - ignored if rstudio_server not installed
#' @param email Email for the git account (a proper email is optional)
#' @param img the name of a docker image (available on docker hub)
#' @param port to host on (default is usually fine)
#' @param browse Only applies if what includes rstudio_server and/or shiny_server
#' @param verbose Print messages (default TRUE)
#'

rstudio <- function(id=NULL, usr='rstudio', pwd='rstudio', email='rstudio@example.com',
                       img='cboettig/rstudio', port='8787', browse=TRUE, verbose=TRUE)
{

  launch_docker <- sprintf('sudo docker run -d -p %s:8787 -e USER=%s -e PASSWORD=%s -e EMAIL=%s %s', 
                  port, usr, pwd, email, img)


  install_string <- sprintf('%s\n%s\n%s\n', install_docker, set_swap, launch_docker)

  stat <- "new"
  while(stat == "new"){
    Sys.sleep(1)
    out <- droplets(id)
    stat <- out$droplets$status
  }
  ip <- out$droplets$ip_address

  # stops function if scp and ssh arent found
  cli_tools(ip)

  # remove known_hosts key
  mssg(verbose, "Removing known host if already present")
  system(sprintf('ssh-keygen -R %s', ip))

  mssg(verbose, "Installing R...")
  r_installed(ip, install_string, verbose)

  rstudiolink <- sprintf("http://%s:%s/", ip, port)
  if(browse) browseURL(rstudiolink) else rstudiolink


}

set_swap <- '
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
'

install_docker <- 'curl -sSL https://get.docker.io/ubuntu/ | sudo sh'
