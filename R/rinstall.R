#' Install stuff on a Digital Ocean droplet
#' 
#' Install one or more of R, RStudio Server, Rstudio Shiny Server
#' 
#' @param id Droplet id
#' @param what One or more of 'nothing', 'r', 'rstudio_server', 'shiny_server'
#' @param usr Username to use to login - ignored if rstudio_server not installed
#' @param pwd Password to use to login - ignored if rstudio_server not installed
#' @param browse Only applies if what includes rstudio_server and/or shiny_server
#' @param verbose Print messages (default TRUE)
#' @examples \dontrun{
#' (res <- do_droplets_new(name="dropwithrstudio", size_id = 64, image_id = 3240036, 
#'    region_slug = 'sfo1', ssh_key_ids = 89103))
#' 
#' do_install(res$droplet$id, what=c('r'))
#' do_install(res$droplet$id, what=c('r','rstudio'), usr='jim', pwd='bob')
#' }

do_install <- function(id=NULL, what='r', usr=NULL, pwd=NULL, browse=TRUE, verbose=TRUE)
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