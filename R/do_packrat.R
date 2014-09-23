#' Use RStudio's packrat to duplicate a project on Digital Ocean
#'
#' @import packrat
#' @export
#' 
#' @param dir A directory, will do path expansion. 
#' @param where The directory to unbundle to on the Droplet
#' @param id A Digital Ocean droplet ID
#' @param what One or more of 'dependencies', 'snapshot', etc.
#' @param rstudio_server (logical) If TRUE, checks for Rstudio Server installed, and opens up 
#' browser with on port 8787 to give you access to your project on your Droplet. Default is 
#' FALSE, which simply prints the directions to login via the shell.
#' @param usr Username to use to login - ignored if rstudio_server not installed
#' @param pwd Password to use to login - ignored if rstudio_server not installed
#' @param verbose Print messages (default TRUE)
#'
#' @details
#' Uses \code{packrat} to do this.
#'
#' @examples \donttest{
#' do_install(id=2688691, what='rstudio_server')
#' do_packrat(dir='~/github/play/dopackplay/', id=2688691)
#' 
#' # From scratch
#' droplets_new(ssh_keys = 89103)
#' do_install(id=2689013, what='rstudio_server')
#' do_packrat(dir='~/github/play/dopackplay/', id=2689013)
#' }

do_packrat <- function(dir=NA, where='~', id, what='snapshot', rstudio_server=TRUE, 
  usr='rstudio', pwd='rstudio', verbose=TRUE)
{
  dir <- path.expand(dir)
  is_droplet(id)
  ip <- get_ip(id)
  
  if('snapshot' %in% what){
    # make snapshot
    packrat::snapshot(dir)
    
    # Try bundle with error catching
    try_bundle(dir)
    
    # get tarfile with path
    tarfile <- bundledtar(dir)
    
    # install packrat on droplet
    writefile("install_packrat.sh", packrat_install_string)
    mssg(verbose, "Installing Packrat...")
    scp_ssh('install_packrat.sh', ip, verbose = verbose)
    
    # move bundled packrat file
    scp(file = tarfile, ip = ip)
    
    # unbundle packrat file on droplet
    prs <- packrat_restore_string(bundledtar(dir, FALSE), where)
    writefile("unbundle.sh", prs)
    mssg(verbose, "Unpacking bundle on Droplet...")
    scp_ssh('unbundle.sh', ip, verbose = verbose)
    
    mssg(verbose, "Success! Your project unbundled on your Droplet")
  }
  
  if('dependencies' %in% what){
    cat("fix me")
  }
  
  if(rstudio_server){
    rstudio_server_installed(ip)
    rstudiolink <- sprintf("http://%s:8787/", ip)
    browseURL(rstudiolink)
  } else {  
    mssg(verbose, sprintf("Log in (ussing ssh key or enter password from email): \n  ssh root@%s", ip))
    sprintf("ssh root@%s", ip)
  }
}

try_bundle <- function(dir){
  tmp <- tryCatch(packrat::bundle(dir), error = function(e) e)
  start <- regexpr("A file", as.character(tmp))
  mg <- substring(as.character(tmp), start, nchar(as.character(tmp)))
  if(is(tmp, "error")) message(mg)
}

bundledtar <- function(dir, fullname=TRUE){
  bundles_path <- path.expand(file.path(dir, "packrat", "bundles"))
  stopifnot(file.exists(bundles_path))
  files <- list.files(bundles_path, pattern = ".tar.gz", full.names = fullname)
  date <- Sys.Date()
  tarfiles <- grep(date, files, value = TRUE)
  # fix me, give prompt
  if(length(tarfiles) > 1) stop("hmmm, more than 1 file from this date") else tarfiles
}

rstudio_server_installed <- function(ip){
  tmp <- tryCatch(GET(sprintf('http://%s:8787', ip)), error = function(e) e)
  if(is(tmp, "error")) warning("Rstudio Server not installed - see ?do_install ")
}

is_droplet <- function(id){
  tmp <- tryCatch(droplets(id), error = function(e) e)
  if(is(tmp, "error")){
    stop(sprintf("%s is not a droplet", id), call. = FALSE)
  } else if(tmp$droplets$data$status != "active"){ 
    stop("Your droplet is not active, check ", call. = FALSE)
  } else { TRUE }
}

packrat_install_string <-
'sudo su - \\\
-c "R -e \\\"install.packages(\'packrat\', repos=\'http://cran.rstudio.com/\')\\\""
'

packrat_restore_string <- 
  function(x,y) sprintf('R -e \"packrat::unbundle(\'%s\', where=\'%s\')\"', x, y)

get_ip <- function(id) {
  stat <- "new"
  while(stat == "new"){
    Sys.sleep(1)
    out <- droplets(id)
    stat <- out$droplets$data$status
  }
  as.character(out$droplets$details$networks_ip_address)
}
