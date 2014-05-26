#' Install stuff on a Digital Ocean droplet
#' 
#' @param what One or more of 'nothing', 'r', 'rstudio_server', 'shiny_server'
#' @param usr Username to use to login - ignored if rstudio_server not installed
#' @param pwd Password to use to login - ignored if rstudio_server not installed
#' @param browse Only applies if what includes rstudio_server and/or shiny_server
#' @param verbose Print messages (default TRUE)
#' 
#' @details
#' Creates a new Digital Ocean Droplet, then installs one or more of R, RStudio Server, Rstudio 
#' Shiny Server. This is all Ubuntu based for now. If you install RStudio Server or Shiny Server, 
#' then R is installed too.
#' 
#' Note that right now droplet creation is done internally to force the details of the new droplet 
#' to be Ubuntu 12.04, so that the appropriate R stuff is easily installed, but machine details 
#' could be made options later.
#' 
#' @examples \dontrun{
#' # Image id 3101045 is an Unbuntu 12.04 x64
#' (res <- do_droplets_new(name="dropthebeat", size_id = 64, image_id = 3101045, 
#'    region_slug = 'sfo1', ssh_key_ids = 89103))
#' do_install(what=c('r'))
#' do_install(what=c('r','rstudio'), usr='jim', pwd='bob')
#' }

do_install <- function(id=NULL, what='r', usr=NULL, pwd=NULL, browse=TRUE, verbose=TRUE,
  rstudio_server_ver='0.98.507', shiny_ver='1.1.0.10000')
{    
  out <- do_droplets_get(id)
  
  
  ip <- out$droplet$ip_address
  
  what <- match.arg(what, c('nothing','r','rstudio_server','shiny_server'))
  if('rstudio_server' %in% what | 'shiny_server' %in% what)
    what <- c(what, 'r')
  
  if('r' %in% what){
    mssg(verbose, "Installing R...")
    installr(verbose, ip)
  }
  
  if('rstudio_server' %in% what){
    mssg(verbose, "Installing RStudio Server...")
    installrstudio(verbose, ip)
    
    rstudiolink <- sprintf("http://%s:8787/", ip)
    if(browse) browseURL(rstudiolink) else rstudiolink
  }
  
  if('shiny_server' %in% what){
    mssg(verbose, "Installing RStudio Shiny Server...")
    installshinyserver(verbose, ip)
    
    shinyserverlink <- sprintf("http://%s:3838/", ip)
    if(browse) browseURL(shinyserverlink) else shinyserverlink
  }
  
  mssg(verbose, sprintf("Log in (then enter password from email): \n  ssh root@%s", ip))
  sprintf("ssh root@%s", ip)
}

installr <- function(verbose, ip){
  # scpfile
  scp_r_cmd <- sprintf('scp doinstallr.sh root@%s:~/', ip)
  system(scp_r_cmd)
  # execute file install R on DO instance
  cmd_r <- sprintf('ssh root@%s "sh doinstallr.sh"', ip)
#   mssg(verbose, cmd_r)
  system(cmd_r)
}

installrstudio <- function(verbose, ip){
  scp_rstudio_cmd <- sprintf('scp doinstall_rstudio.sh root@%s:~/', ip)
  system(scp_rstudio_cmd)
  
  cmd_rstudio <- sprintf('ssh root@%s "sh doinstall_rstudio.sh"', ip)
#   mssg(verbose, cmd_rstudio)
  system(cmd_rstudio)
}

installshinyserver <- function(verbose, ip){
  scp_shiny_cmd <- sprintf('scp doinstall_shiny.sh root@%s:~/', ip)
  system(scp_shiny_cmd)
  
  cmd_shiny <- sprintf('ssh root@%s "sh doinstall_shiny.sh"', ip)
  system(cmd_shiny)
}

mssg <- function(x, y) if(x) message(y)

# installr <- '
# sudo echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
# sudo apt-get update --yes --force-yes
# sudo apt-get install r-base-dev --yes --force-yes
# '
# 
# installrstudio_ <- '
# sudo apt-get install gdebi-core --yes --force-yes
# sudo apt-get install libapparmor1 --yes --force-yes
# wget http://download2.rstudio.org/rstudio-server-%s-amd64.deb
# sudo gdebi rstudio-server-%s-amd64.deb --non-interactive
# adduser %s --disabled-password --gecos ""
# echo "%s:%s"|chpasswd
# '
# installrstudio <- sprintf(installrstudio_, rstudio_server_ver, rstudio_server_ver, usr, usr, pwd)
# 
# installshiny_ <- '
# sudo su - \
#     -c "R -e \"install.packages("shiny", repos="http://cran.rstudio.com/")\""
# sudo apt-get install gdebi-core --yes --force-yes
# wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-%s-amd64.deb
# sudo gdebi shiny-server-%s-amd64.deb --non-interactive
# '
# 
# installshiny <- sprintf(installshiny_, shiny_ver, shiny_ver)