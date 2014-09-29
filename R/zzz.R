list_to_object <- function(x, singular, plural = paste0(singular, "s"),
                  name = "name", class = singular) {
  if (!is.null(x[[plural]])) {
    objs <- lapply(x[[plural]], structure, class = class)
    if (!is.null(name)) {
      names(objs) <- pluck(x[[plural]], name, character(1))
    }
    objs
  } else if (!is.null(x[[singular]])) {
    structure(x[[singular]], class = class)
  } else {
    stop("Don't know how to coerce this list to a ", class , call. = FALSE)
  }
}


mssg <- function(x, y) if(x) message(y)

writefile <- function(filename, installstring){
  installrfile = filename
  fileConn <- file(installrfile)
  writeLines(installstring, fileConn)
  close(fileConn)
}

cli_tools <- function(ip){
  tmp <- Sys.which(c("ssh","scp"))
  nf <- names(tmp[vapply(tmp, nchar, 1) == 0])
  if(length(nf) != 0)
    stop(sprintf("%s not found on your computer\nTry ssh'ing into the machine\n    (ssh root@%s)\n& manually installing things. See ?do_scripts for help", nf, ip))
}


#' Set Digital Ocean options including ssh keys, etc.
#'
#' This function sets options and prints them so you know what options are set.
#'
#' @export
#' @param size (optional) A Digital Ocean size slug name, e.g. '1gb'. Saved in options as 'do_size'
#' @param image (optional) A Digital Ocean image name, e.g., 'ubuntu-14-04-x64'. Saved in
#' options as 'do_image'
#' @param region (optional) A Digital Ocean region name, e.g., 'nyc1'. Saved in options
#' as 'do_region'
#' @param ssh_keys (optional) One or more ssh key id numbers or fingerprints. Put many in a list
#' or vector. Saved in options as 'do_ssh_keys'
#' @param private_networking (optional) A logical, whether to use private networking or not.
#' Saved in options as 'do_private_networking'
#' @param backups (optional) A logical, whether to enable backups. Automated backups can only be
#' enabled when the Droplet is created. Saved in options as 'do_backups'
#' @param ipv6 (optional) A boolean indicating whether IPv6 is enabled on the Droplet. Saved in
#' options as 'do_ipv6'
#' @param unset (optional) A boolean. If TRUE, unsets options so as to use defaults in
#' \code{droplets_new}. If FALSE (default) your options are used in \code{droplets_new}.
#'
#' @details
#' These options are read and used by \code{droplets_new}.
#'
#' You can only set one value for each of size, image, and region, but multiple
#' values for ssh_keys as you can use multiple ssh keys on one DO droplet.
#'
#' Keep in mind that there are defaults set for size, image, and region in \code{droplets_new}.
#'
#' @examples \dontrun{
#' do_options()
#' do_options(ssh_keys=89103)
#' getOption('do_ssh_keys')
#' do_options(size="8gb")
#' do_options(size="1gb", image='ubuntu-14-04-x64', region='nyc1')
#' getOption('do_size')
#' getOption('do_image')
#' getOption('do_region')
#' }
do_options <- function(size=NULL, image=NULL, region=NULL, ssh_keys=NULL, private_networking=NULL,
  backups=NULL, ipv6=NULL, unset=FALSE)
{
  if(!unset){
    if(!is.null(size)) options(do_size = size)
    if(!is.null(image)) options(do_image = image)
    if(!is.null(region)) options(do_region = region)
    if(!is.null(ssh_keys)) options(do_ssh_keys = ssh_keys)
    if(!is.null(private_networking)) options(do_private_networking = private_networking)
    if(!is.null(backups)) options(do_backups = backups)
    if(!is.null(ipv6)) options(do_ipv6 = ipv6)
  } else {
    options(do_size = NULL); options(do_image = NULL); options(do_region = NULL)
    options(do_ssh_keys = NULL); options(do_private_networking = NULL)
    options(do_backups = NULL); options(do_ipv6 = NULL)
  }


  cat("Your analogsea default options for spinning up a new droplet:", "\n")
  cat("[size]", gopt('do_size', 'not set (Defaults to: 512mb)'), "\n")
  cat("[image]", gopt('do_image', 'not set (Defaults to: ubuntu-14-04-x64)'), "\n")
  cat("[region]", gopt('do_region', 'not set (Defaults to: sfo1)'), "\n")
  cat("[ssh keys]", gopt('do_ssh_keys'), "\n")
  cat("[private networking]", gopt('do_private_networking'), "\n")
  cat("[backups]", gopt('do_backups'), "\n")
  cat("[ipv6]", gopt('do_ipv6'))
}

gopt <- function(x, y='not set') getOption(x, y)
gopt2 <- function(c, a, b) if(!is.null(c)) eval(c) else getOption(a, b)

nn <- function(x, unbox=TRUE){
  z <- switch(deparse(substitute(x)),
         name = eval(x),
         size = gopt2(x, 'do_size', '512mb'),
         image = gopt2(x, 'do_image', 'ubuntu-14-04-x64'),
         region = gopt2(x, 'do_region', 'sfo1'),
         ssh_keys = gopt2(x, 'do_ssh_keys', NULL),
         private_networking = gopt2(x, 'do_private_networking', NULL),
         backups = gopt2(x, 'do_backups', NULL),
         ipv6 = gopt2(x, 'do_ipv6', NULL)
  )
  if(is.null(z)) z else if(unbox) jsonlite::unbox(z) else z
}

compact <- function(x) Filter(Negate(is.null), x)

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

`%||%` <- function(a, b) if (is.null(a)) b else a
