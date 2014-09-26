
#' Create a new droplet.
#'
#' There are defaults for each of size, image, and region so that a quick one-liner with one
#' parameter is possible: simply specify the name of the droplet and your'e up and running.
#'
#' @export
#' @param name (character) Name of the droplet. Default: picks a random name if none supplied.
#' @param size (character) Size slug identifier. See \code{sizes}. Default: 512mb, the smallest
#' @param image (character/numeric) The image ID of a public or private image, or the unique slug
#' identifier for a public image. This image will be the base image for your Droplet.
#' Default: ubuntu-14-04-x64
#' @param region (character) The unique slug identifier for the region that you wish to deploy in.
#' Default: sfo1
#' @param ssh_keys (character) A vector with IDs or fingerprints of the SSH keys that you wish to
#' embed in the Droplet's root account upon creation.
#' @param private_networking (logical) Use private networking. Private networking is currently
#' only available in certain regions. Default: FALSE
#' @param backups (logical) Enable backups. A boolean indicating whether automated backups should
#' be enabled for the Droplet. Automated backups can only be enabled when the Droplet is created.
#' Default: FALSE
#' @param ipv6 (logical) A boolean indicating whether IPv6 is enabled on the Droplet.
#' @template whatconfig
#' @examples \dontrun{
#' droplet_new()
#' droplet_new('droppinit')
#' droplet_new(name="newdrop", size = '512mb', image = 'ubuntu-14-04-x64', region = 'sfo1')
#' droplet_new(ssh_keys=89103)
#' }
droplet_new <- function(name = random_name(), size = NULL, image = NULL, 
                        region = NULL,  ssh_keys = NULL, backups = NULL, 
                        ipv6 = NULL, private_networking = FALSE, ...) {
  
  if (is.null(ssh_keys)) {
    all_keys <- keys()
    if (length(all_keys) >= 1) {
      message("Using default ssh key: ", all_keys[[1]]$name)
      ssh_keys <- all_keys[[1]]$id
    }
  }
  
  res <- do_POST('droplets', 
    body = list(
      name = nn(name), 
      size = nn(size), 
      image = nn(image), 
      region = nn(region), 
      ssh_keys = nn(ssh_keys, FALSE), 
      backups = nn(backups), 
      ipv6 = nn(ipv6), 
      private_networking = nn(private_networking)
    ), ...
  )
  droplet <- structure(res$droplet, class = "droplet")
  
  message("NB: This costs $", droplet$size$price_hourly, " / hour ", 
    " until you droplete_delete() it")
  droplet
}

random_name <- function() sample(words, size = 1)

#' Delete a droplet.
#'
#' This method deletes one of your droplets - this is irreversible.
#'
#' @export
#' @param droplet A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param ... Additional options passed down to low-level API method.
#' @param config Options passed on to httr::GET. Must be named, see examples.
#' @examples
#' \dontrun{
#' drops <- droplets()
#' drops[[1]] %>% droplet_delete()
#' drops[[2]] %>% droplet_delete()
#' droplet_new() %>% droplet_delete()
#' 
#' droplet_delete("lombard")
#' droplet_delete(12345)
#' }
droplet_delete <- function(droplet, ...) {
  droplet <- as.droplet(droplet)
  do_DELETE(sprintf('droplets/%s', id), ...)
}


#' Perform various actions on a droplet.
#'
#' These droplet actions have no further arguments.
#'
#' \describe{
#' \item{reboot}{This method allows you to reboot a droplet. This is 
#'   the preferred method to use if a server is not responding}
#' \item{powercycle}{This method allows you to power cycle a droplet.
#'    This will turn off the droplet and then turn it back on.}
#' \item{shutdown}{Shutdown a running droplet. The droplet will remain in 
#'   your account and you will continue to be charged for it.}
#' \item{power_off}{Shutdown a running droplet. The droplet will remain in 
#'   your account and you will continue to be charged for it.}
#' \item{reset_password}{This method will reset the root password for a 
#'   droplet. Please be aware that this will reboot the droplet to allow 
#'   resetting the password.}
#' \item{enable_ipv6}{Enable IPv6 networking on an existing droplet (within 
#'   a region that has IPv6 available).}
#' \item{enable_private_networking}{Enable private networking on an existing  
#'   droplet (within a region that has private networking available)}
#' \item{disable_backups}{Disables backups for a droplet.}
#' \item{power_on}{Turn on a droplet that's turned off.}
#' }
#' @inheritParams droplet_delete
#' @examples \dontrun{
#' d <- droplets()
#' d[[1]] %>% droplet_reboot()
#' d[[2]] %>% droplet_power_cycle()
#' }
#' @name droplet_action
NULL

#' @export
#' @rdname droplet_action
droplet_reboot <- function(droplet, ...) {
  droplet_action("reboot", droplet, ...)
}

#' @export
#' @rdname droplet_action
droplet_power_cycle <- function(droplet, ...) {
  droplet_action("power_cycle", droplet, ...)
}

#' @export
#' @rdname droplet_action
droplet_shutdown <- function(droplet, ...) {
  droplet_action("shutdown", droplet, ...)
}

#' @export
#' @rdname droplet_action
droplet_power_off <- function(droplet, ...) {
  droplet_action("power_off", droplet, ...)
}

#' @export
#' @rdname droplet_action
droplet_power_on <- function(droplet, ...) {
  droplet_action("power_on", droplet, ...)
}

#' @export
#' @rdname droplet_action
droplet_reset_password <- function(droplet, ...) {
  droplet_action("reset_password", droplet, ...)
}

#' @export
#' @rdname droplet_action
droplet_enable_ipv6 <- function(droplet, ...) {
  droplet_action("enable_ipv6", droplet, ...)
}

#' @export
#' @rdname droplet_action
droplet_enable_private_networking <- function(droplet, ...) {
  droplet_action("enable_private_networking", droplet, ...)
}

#' @export
#' @rdname droplet_action
droplet_disable_backups <- function(droplet, ...) {
  droplet_action("disable_backups", droplet, ...)
}

droplet_action <- function(action, droplet, ...) {
  droplet <- as.droplet(droplet)
  
  res <- do_POST(sprintf('droplets/%s/actions', droplet$id), query = list(
    type = jsonlite::unbox(action),
    ...)
  )
  as.action(res)
}


#' Modify a droplet.
#' 
#' These methods allow you to modify existing droplets.
#' 
#' \describe{
#' \item{resize}{Resize a specific droplet to a different size. This will 
#'   affect the number of processors and memory allocated to the droplet.}
#' \item{rebuild}{Reinstall a droplet with a default image. This is useful if you want
#'   to start again but retain the same IP address for your droplet.}
#' \item{rename}{Change the droplet name}
#' \item{change_kernel}{Change kernel ID.}
#' }
#' 
#' @param x A droplet number or the result from a call to \code{droplets}
#' @param size (character) Size slug (name) of the image size. See \code{sizes}
#' @examples \dontrun{
#' droplets_resize(2427664, size='1gb')
#'
#' droplets() %>%
#'    droplets_power_off %>%
#'    droplets_resize(size = '1gb') %>%
#'    events
#' }
#' @name droplet_modify
NULL

#' @export
#' @rdname droplet_modify
droplet_resize <- function(droplet, size, ...) {
  droplet_action("resize", droplet, size = jsonlite::unbox(size), ...)
}

#' @export
#' @rdname droplet_modify
droplet_rebuild <- function(droplet, image) {
  droplet_action("rebuild", droplet, image = jsonlite::unbox(image), ...)
}

#' @export
#' @rdname droplet_modify
#' @param name (character) The new name for the droplet
droplet_rename <- function(droplet, name) {
  droplet_action("rename", droplet, name = jsonlite::unbox(name), ...)
}

#' @export
#' @rdname droplet_modify
#' @param kernel (numeric) The ID of the new kernel.
droplet_change_kernel <- function(droplet, kernel) {
  droplet_action("change_kernel", droplet, kernel = jsonlite::unbox(kernel), 
    ...)
}

#' Take and restore snapshots.
#' 
#' \describe{
#' \item{snapshot}{Take a snapshot of the droplet once it has been powered 
#'   off, which can later be restored or used to create a new droplet from 
#'   the same image. Please be aware this may cause a reboot.}
#' \item{snapshots_list}{List available snapshots}
#' \item{backups_list}{List available snapshots}
#' \item{restore}{Restore a droplet with a previous image or snapshot. 
#'   This will be a mirror copy of the image or snapshot to your droplet. Be 
#'   sure you have backed up any necessary information prior to restore.}
#' }
#'
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @param name (character) Optional. Name of the new snapshot you want to 
#'   create. If not set, the  snapshot name will default to the current date/time
#' @template whatconfig
#' @examples \dontrun{
#' d <- droplet_new()
#' d %>% droplet_snapshots_list()
#' d %>% droplet_backups_list()
#' 
#' d %>% 
#'   droplet_power_off() %>%
#'   droplet_snapshot() %>%
#'   droplet_power_on() %>%
#'   droplet_snapshots_list()
#'   
#' # To delete safely
#' d %>% 
#'   droplet_power_off() %>%
#'   droplet_snapshot() %>%
#'   droplet_delete() %>% 
#'   action_wait()
#' }
#' @export
droplet_snapshot <- function(droplet, image = NULL, ...) {
  droplet_action("snapshot", droplet, name = image, ...)
}

#' @export
#' @rdname droplet_snapshot
droplet_snapshots_list <- function(droplet, ...) {
  droplet <- as.droplet(droplet)
  
  res <- do_GET(sprintf('droplets/%s/snapshots', droplet$id), ...)
  res$snapshots
}

#' @export
#' @rdname droplet_snapshot
droplet_restore <- function(droplet, image) {
  droplet_action("restore", droplet, image = jsonlite::unbox(image), ...)
}

#' @export
#' @rdname droplet_snapshot
droplet_backups_list <- function(droplet, ...) {
  droplet <- as.droplet(droplet)
  
  res <- do_GET(sprintf('droplets/%s/backups', droplet$id), ...)
  res$backups
}


#' List all available kernels for a droplet.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets()[[1]] %>% droplet_kernels_list
#' }
droplet_kernels_list <- function(droplet, ...) {
  droplet <- as.droplet(droplet)
  
  res <- do_GET(sprintf('droplets/%s/kernels', droplet$id), ...)
  res$kernels
}

#' Retrieve a droplet action or list all actions associatd with a droplet.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @param actionid (integer) Optional. An action id.
#' @template whatconfig
#' @examples \dontrun{
#' droplets_actions(2428384)
#' droplets_actions(2428384, actionid=31223385)
#' }
droplet_actions <- function(droplet) {
  droplet <- as.droplet(droplet)
  
  res <- do_GET(sprintf('droplets/%s/actions', droplet$id))
  lapply(res$actions, as.action)
}
