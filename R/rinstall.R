#' Install stuff on a Digital Ocean droplet
#' 
#' @export
#' @param id A Digital Ocean droplet ID
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
#' Note that Shiny installs but isn't working right. RStudio Server installs and works great.
#' 
#' @examples \dontrun{
#' # Image slug 'ubuntu-14-04-x64' is an Unbuntu 14.04 x64 box with 512 mb given by size_slug param
#' (res <- do_droplets_new(name="foo", size_slug = '512mb', image_slug = 'ubuntu-14-04-x64',
#'    region_slug = 'sfo1', ssh_key_ids = 89103))
#' do_install(id=res$droplet$id, what='r')
#' do_install(res$droplet$id, what='rstudio', usr='jim', pwd='bob')
#' do_install(res$droplet$id, what='shiny')
#' do_install(res$droplet$id, what='r', deps=c('xml','curl'))
#' do_install(res$droplet$id, what='r', deps=c('xml','curl','gdal','rcpp'))
#' }

do_install <- function(id=NULL, what='r', deps=NULL, usr=NULL, pwd=NULL, browse=TRUE, verbose=TRUE,
  rstudio_server_ver='0.98.507', shiny_ver='1.1.0.10000')
{    
  stat <- "new"
  while(stat == "new"){
    Sys.sleep(1)
    out <- do_droplets_get(id)
    stat <- out$droplet$status
  }
  ip <- out$droplet$ip_address

  # remove known_hosts key
  mssg(verbose, "Removing known host if already present")
  system(sprintf('ssh-keygen -R %s', ip))
  
  what <- match.arg(what, c('nothing','r','rstudio_server','shiny_server'))
  
  if('nothing' %in% what){
    message("Nothing installed...stoppings")
  } else {
    if('r' %in% what){
      writefile("doinstallr.sh", r_string)
      mssg(verbose, "Installing R...")
      installr(verbose, ip)
    }
    
    if(!is.null(deps)){
      chr <- tryCatch(system(sprintf('ssh root@%s "which R"', ip), intern=TRUE), warning=function(e) e)
      if("warning" %in% class(chr)){
        writefile("doinstallr.sh", r_string)
        mssg(verbose, "Installing R...")
        installr(verbose, ip)
      }
      
      deps <- match.arg(deps, c("xml","curl","gdal","rcpp"), TRUE)
      depstomatch <- c("r-cran-xml","libcurl4-openssl-dev","gdal-bin libgdal-dev libproj-dev","r-cran-rcpp")
      depinstall <- vapply(deps, function(x) grep(x, depstomatch, value = TRUE), "", USE.NAMES = FALSE)
      depinstall <- paste(depinstall, collapse = " ")
      
      deps_string2 <- sprintf(dep_string, depinstall)
      writefile("doinstall_deps.sh", deps_string2)
      
      mssg(verbose, "Installing dependencies...")
      installdeps(verbose, ip)
    }
    
    if('rstudio_server' %in% what){
      chr <- tryCatch(system(sprintf('ssh root@%s "which R"', ip), intern=TRUE), warning=function(e) e)
      if("warning" %in% class(chr)){
        writefile("doinstallr.sh", r_string)
        mssg(verbose, "Installing R...")
        installr(verbose, ip)
      }
      
      rstudio_string2 <- sprintf(rstudio_string, rstudio_server_ver, rstudio_server_ver, usr, usr, pwd)
      writefile("doinstall_rstudio.sh", rstudio_string2)
      
      mssg(verbose, "Installing RStudio Server...")
      installrstudio(verbose, ip)
      
      rstudiolink <- sprintf("http://%s:8787/", ip)
      if(browse) browseURL(rstudiolink) else rstudiolink
    }
    
    if('shiny_server' %in% what){
      chr <- tryCatch(system(sprintf('ssh root@%s "which R"', ip), intern=TRUE), warning=function(e) e)
      if("warning" %in% class(chr)){
        writefile("doinstallr.sh", r_string)
        mssg(verbose, "Installing R...")
        installr(verbose, ip)
      }
      
      shiny_string2 <- sprintf(shiny_string, shiny_ver, shiny_ver)
      writefile("doinstall_shiny.sh", shiny_string2)
      
      mssg(verbose, "Installing RStudio Shiny Server...")
      installshinyserver(verbose, ip)
      
      shinyserverlink <- sprintf("http://%s:3838/", ip)
      if(browse) browseURL(shinyserverlink) else shinyserverlink
    }
  }

  mssg(verbose, sprintf("Log in (ussing ssh key or enter password from email): \n  ssh root@%s", ip))
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

installdeps <- function(verbose, ip){
  scp_deps_cmd <- sprintf('scp doinstall_deps.sh root@%s:~/', ip)
  system(scp_deps_cmd)
  
  cmd_deps <- sprintf('ssh root@%s "sh doinstall_deps.sh"', ip)
  system(cmd_deps)
}

mssg <- function(x, y) if(x) message(y)

r_string <- 
'sudo echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo apt-get update --yes --force-yes
sudo apt-get install r-base-core r-base-dev --yes --force-yes'

rstudio_string <- 
'sudo apt-get install gdebi-core --yes --force-yes
sudo apt-get install libapparmor1 --yes --force-yes
wget http://download2.rstudio.org/rstudio-server-%s-amd64.deb
sudo gdebi rstudio-server-%s-amd64.deb --non-interactive
adduser %s --disabled-password --gecos ""
echo "%s:%s"|chpasswd'

shiny_string <- 
'apt-get install r-cran-shiny
sudo apt-get install gdebi-core --yes --force-yes
wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-%s-amd64.deb
sudo gdebi shiny-server-%s-amd64.deb --non-interactive'

dep_string <- 'sudo apt-get install %s --yes --force-yes'

writefile <- function(filename, installstring){  
  installrfile = filename
  fileConn <- file(installrfile)
  writeLines(installstring, fileConn)
  close(fileConn)
}