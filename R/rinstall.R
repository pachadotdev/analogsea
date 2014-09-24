#' Install stuff on a Digital Ocean droplet
#'
#' @export
#' @param id A Digital Ocean droplet ID
#' @param what One or more of 'nothing', 'r', 'rstudio_server', 'shiny_server'
#' @param deps (character) One or more dependencies to install. Currently supported are: libcurl,
#' libxml, gdal, and rcpp. We'll add more as time goes on. This is intended to install things that
#' you often have to drop down into the terminal and ssh into the machine to install.
#' @param usr Username to use to login - ignored if rstudio_server not installed
#' @param pwd Password to use to login - ignored if rstudio_server not installed
#' @param browse Only applies if what includes rstudio_server and/or shiny_server
#' @param verbose Print messages (default TRUE)
#' @param rstudio_server_ver RStudio server version number.
#' @param shiny_ver RStudio Shiny version number.
#' @param swap (logical) Set swap on DO machine - allows enough memory to install things.
#' Default: TRUE
#' @param mirror The mirror to set from which to install R packages. Default: 
#' 'http://cran.rstudio.com/'
#'
#' @details
#' Installs one or more of R, RStudio Server, Rstudio Shiny Server, OpenCPU. This is all Ubuntu
#' based for now. If you install RStudio Server or Shiny Server, then R is installed too. By
#' default, we set swap memory so that you have enough memory on the DO machine to install things.
#'
#' Note that Shiny installs but isn't working right. RStudio Server installs and works.
#'
#' OpenCPU doesn't work yet either.
#'
#' @examples \dontrun{
#' # Image slug 'ubuntu-14-04-x64' is an Unbuntu 14.04 x64 box with 512 mb given by size_slug param
#' (res <- droplets_new(name="foo", size_slug = '512mb', image_slug = 'ubuntu-14-04-x64',
#'    region_slug = 'sfo1', ssh_key_ids = 89103))
#' do_install(id=res$droplet$id, what='r')
#' do_install(res$droplet$id, what='rstudio', usr='jim', pwd='bob')
#' do_install(res$droplet$id, what='shiny')
#' do_install(id=1987605, what='opencpu')
#' do_install(res$droplet$id, what='r', deps=c('xml','curl'))
#' do_install(res$droplet$id, what='r', deps=c('xml','curl','gdal','rcpp'))
#' 
#' 
#' id <- droplets()$droplets$data$id
#' do_install(id=id, what='r')
#' 
#' droplets_new(ssh_keys = 89103)
#' droplets()
#' id <- droplets()$droplet_ids
#' do_install(id=id, what='r')
#' do_install(id=id, deps=c('xml','curl'))
#' do_install(id=id, what='rstudio_server')
#' do_install(id=id, what='shiny_server')
#' 
#' droplets_new(ssh_keys = 89103)
#' droplets()
#' id <- droplets()$droplet_ids[2]
#' do_install(id=id, what='shiny_server')
#' }

do_install <- function(id=NULL, what='r', deps=NULL, usr='rstudio', pwd='rstudio', browse=TRUE, verbose=TRUE,
  rstudio_server_ver='0.98.1062', shiny_ver='1.2.1.362', swap=TRUE, mirror='http://cran.rstudio.com/')
{
  # Get ip addrres, waiting until status='active'
  ip <- get_ip(id)

  # stops function if scp and ssh arent found
  cli_tools(ip)
  
  # stop if mirror is not found
  check_mirror(mirror)

  # remove known_hosts key
#   mssg(verbose, "Removing known host if already present")
#   system(sprintf('ssh-keygen -R %s', ip))

  what <- match.arg(what, c('nothing','r','rstudio_server','shiny_server','opencpu'))

  if('nothing' %in% what){
    message("Nothing installed...stopping")
  } else {
    if('r' %in% what){
      writefile("doinstallr.sh", r_string)
      mssg(verbose, "Installing R...")
      scp_ssh('doinstallr.sh', ip, verbose = verbose)
      do_swap(swap, ip, swap_string, verbose)
    }

    if(!is.null(deps)){
      do_swap(swap, ip, swap_string, verbose)
      r_installed(ip, r_string, verbose)

      deps <- match.arg(deps, c("xml","curl","gdal","rcpp"), TRUE)
      depstomatch <- c("r-cran-xml","libcurl4-openssl-dev","gdal-bin libgdal-dev libproj-dev","r-cran-rcpp")
      depinstall <- vapply(deps, function(x) grep(x, depstomatch, value = TRUE), "", USE.NAMES = FALSE)
      depinstall <- paste(depinstall, collapse = " ")

      deps_string2 <- sprintf(dep_string, depinstall)
      writefile("doinstall_deps.sh", deps_string2)

      mssg(verbose, "Installing dependencies...")
      scp_ssh('doinstall_deps.sh', ip, verbose = verbose)
    }

    if('rstudio_server' %in% what){
      do_swap(swap, ip, swap_string, verbose)
      r_installed(ip, r_string, verbose)

      rstudio_string2 <- sprintf(rstudio_string, rstudio_server_ver, rstudio_server_ver, usr, usr, pwd)
      writefile("doinstall_rstudio.sh", rstudio_string2)

      mssg(verbose, "Installing RStudio Server...")
      scp_ssh('doinstall_rstudio.sh', ip, verbose = verbose)

      rstudiolink <- sprintf("http://%s:8787/", ip)
      if(browse) browseURL(rstudiolink) else rstudiolink
    }

    if('shiny_server' %in% what){
      do_swap(swap, ip, swap_string, verbose)
      r_installed(ip, r_string, verbose)

      shiny_string2 <- sprintf(shiny_string, shiny_ver, shiny_ver)
      writefile("doinstall_shiny.sh", shiny_string2)

      mssg(verbose, "Installing RStudio Shiny Server...")
      scp_ssh('doinstall_shiny.sh', ip, verbose = verbose)

      shinyserverlink <- sprintf("http://%s:3838/", ip)
      if(browse) browseURL(shinyserverlink) else shinyserverlink
    }

    if('opencpu' %in% what){
      do_swap(swap, ip, swap_string, verbose)
      r_installed(ip, r_string, verbose)

      writefile("doinstall_opencpu.sh", opencpu_string)

      mssg(verbose, "Installing OpenCPU...")
      scp_ssh('doinstall_opencpu.sh', ip, verbose = verbose)

      opencpu_link <- sprintf("http://%s/ocpu/test", ip)
      if(browse) browseURL(opencpu_link) else opencpu_link
    }
  }

  mssg(verbose, sprintf("Log in (ussing ssh key or enter password from email): \n  ssh root@%s", ip))
  sprintf("ssh root@%s", ip)
}

scp_ssh <- function(file, ip, user='root', verbose){
  # remove known_hosts key
  mssg(verbose, "Removing known host if already present")
  system(sprintf('ssh-keygen -R %s', ip))
  scp(file, ip, user)
  ssh(file, ip, user)
}

scp <- function(file, ip, user='root'){
  scp_cmd <- sprintf('scp -o StrictHostKeyChecking=no %s %s@%s:~/', file, user, ip)
  system(scp_cmd)
}

ssh <- function(file, ip, user='root'){
  ssh_cmd <- sprintf('ssh %s@%s "sh %s"', user, ip, file)
  system(ssh_cmd)
}

r_string <-
'sudo echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo apt-get update --yes --force-yes
sudo apt-get install r-base-core r-base-dev --yes --force-yes
echo "options(repos=c(\'http://cran.rstudio.com/\'))" > .Rprofile'

rstudio_string <-
'sudo apt-get install gdebi-core --yes --force-yes
sudo apt-get install libapparmor1 --yes --force-yes
wget http://download2.rstudio.org/rstudio-server-%s-amd64.deb
sudo gdebi rstudio-server-%s-amd64.deb --non-interactive
adduser %s --disabled-password --gecos ""
echo "%s:%s"|chpasswd'

shiny_string <-
# apt-get install r-cran-shiny
'
sudo su - \\\
-c "R -e \\\"install.packages(\'shiny\', repos=\'http://cran.rstudio.com/\')\\\""
sudo su - \\\
-c "R -e \\\"install.packages(\'rmarkdown\', repos=\'http://cran.rstudio.com/\')\\\""
sudo apt-get install gdebi-core --yes --force-yes
wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-%s-amd64.deb
sudo gdebi shiny-server-%s-amd64.deb --non-interactive'

#requires ubuntu 14.04 (Trusty)
opencpu_string <-
'sudo add-apt-repository ppa:opencpu/opencpu-1.4
sudo apt-get update
sudo apt-get -q -y install opencpu
sudo service opencpu start'

dep_string <- 'sudo apt-get install %s --yes --force-yes'

swap_string <- 
'sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile'

r_installed <- function(ip, r_string, verbose){
  chr <- tryCatch(system(sprintf('ssh root@%s "which R"', ip), intern=TRUE), warning=function(e) e)
  if("warning" %in% class(chr)){
    writefile("doinstallr.sh", r_string)
    mssg(verbose, "Installing R...")
    scp_ssh('doinstallr.sh', ip, verbose = verbose)
  }
}

do_swap <- function(swap, ip, swap_string, verbose){
  if(is_swap_not_set(ip)){
    if(swap){
      writefile("setswap.sh", swap_string)
      mssg(verbose, "Setting swap...")
      scp_ssh('setswap.sh', ip, verbose = verbose)
    }
  }
}

is_swap_not_set <- function(ip){
  chr <- tryCatch(system(sprintf('ssh root@%s "ls | grep setswap.sh"', ip), intern=TRUE), warning=function(e) e)
  if("warning" %in% class(chr)) TRUE else FALSE
}

check_mirror <- function(x){
  mirrors <- getCRANmirrors()
  match <- grepl(x, mirrors$URL)
  if(!any(match)) stop(sprintf("%s is not in the list of R mirrors at http://cran.r-project.org/CRAN_mirrors.csv", x))
}
