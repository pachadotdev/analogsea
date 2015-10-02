#' Set Digital Ocean options including ssh keys, etc.
#'
#' This function sets options and prints them so you know what options are set.
#'
#' @export
#' @param size (optional) A Digital Ocean size slug name, e.g. '1gb'. Saved in options
#' as 'do_size'
#' @param image (optional) A Digital Ocean image name, e.g., 'ubuntu-14-04-x64'. Saved in
#' options as 'do_image'
#' @param region (optional) A Digital Ocean region name, e.g., 'nyc1'. Saved in options
#' as 'do_region'
#' @param ssh_keys (optional) One or more ssh key id numbers or fingerprints. Put many in
#' a list or vector. Saved in options as 'do_ssh_keys'
#' @param private_networking (optional) A logical, whether to use private networking or not.
#' Saved in options as 'do_private_networking'
#' @param backups (optional) A logical, whether to enable backups. Automated backups can
#' only be enabled when the Droplet is created. Saved in options as 'do_backups'
#' @param ipv6 (optional) A boolean indicating whether IPv6 is enabled on the Droplet.
#' Saved in options as 'do_ipv6'
#' @param unset (optional) A boolean. If TRUE, unsets options so as to use defaults in
#' \code{\link{droplet_create}}. If \code{FALSE} (default) your options are used in
#' \code{\link{droplet_create}}.
#'
#' @details
#' These options are read and used by \code{\link{droplet_create}}.
#'
#' You can only set one value for each of size, image, and region, but multiple
#' values for ssh_keys as you can use multiple ssh keys on one DO droplet.
#'
#' Keep in mind that there are defaults set for size, image, and region
#' in \code{\link{droplet_create}}.
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
do_options <- function(size = NULL, image = NULL, region = NULL, ssh_keys = NULL,
                       private_networking = NULL, backups = NULL, ipv6 = NULL,
                       unset = FALSE) {

  if (!unset) {
    new_opts = ascompact(list(
      do_size = size,
      do_image = image,
      do_region = region,
      do_ssh_keys = ssh_keys,
      do_private_networking = private_networking,
      do_backups = backups,
      do_ipv6 = ipv6
    ))
  } else {
    new_opts = list(
      do_size = NULL,
      do_image = NULL,
      do_region = NULL,
      do_ssh_keys = NULL,
      do_private_networking = NULL,
      do_backups = NULL,
      do_ipv6 = NULL
    )
  }
  if (length(new_opts) > 0)
    options(new_opts)

  cat("Default options for spinning up a new droplet:", "\n")
  cat("[size]:     ", getOption("do_size", "not set (Defaults to: 512mb)"), "\n")
  cat("[image]:    ", getOption("do_image", "not set (Defaults to: ubuntu-14-04-x64)"), "\n")
  cat("[region]:   ", getOption("do_region", "not set (Defaults to: sfo1)"), "\n")
  cat("[ssh keys]: ", getOption("do_ssh_keys"), "\n")
  cat("[private networking]", getOption("do_private_networking"), "\n")
  cat("[backups]:  ", getOption("do_backups"), "\n")
  cat("[ipv6]:     ", getOption("do_ipv6"))
}
