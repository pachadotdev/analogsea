#' List all droplets, or retrieve single droplet.
#'
#' @export
#' @param id A droplet id.
#' @examples \dontrun{
#' droplets()
#'
#' # Get info on a single droplet, passing in a list of droplet details
#' drops <- droplets()
#' drops[[1]]
#'
#' # Get info on a single droplet, passing in a numeric droplet id
#' droplets(droplet=1746449)
#' }
droplets <- function(...) {
  res <- do_droplets(...)
  droplets <- lapply(res$droplets, structure, class = "droplet")
  names(droplets) <- vapply(res$droplets, function(x) x$name, character(1))
  droplets
}

#' @export
#' @rdname droplets_list
do_droplets <- function(page = 1, per_page = 25, config = NULL) {
  do_GET("parsed", "droplets", 
    query = list(page = page, per_page = per_page), 
    config = config, parse = FALSE
  )
}

#' @export
#' @rdname droplets_list
droplet <- function(id, ...) {
  x <- do_droplet(id, ...)$droplet
  structure(x, class = "droplet")
}

#' @export
print.droplet <- function(x, ...) {
  cat("<droplet>", x$name, " (", x$id, ")\n", sep = "")
  cat("  Region: ", x$region$name, "\n", sep = "")
  cat("  Image: ", x$image$name, "\n", sep = "")
  cat("  Size: ", x$size$slug, " ($", x$size$price_hourly, " / hr)" ,"\n", sep = "") 
}

#' @export
#' @rdname droplets_list
do_droplet <- function(id, config = NULL) {
  do_GET("parsed", sprintf("droplets/%s", id), 
    config = config, parse = FALSE
  )
}

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
droplet_new <- function(name=NULL, size=NULL, image=NULL, region=NULL, 
                        ssh_keys=NULL, backups=NULL, ipv6=NULL, 
                        private_networking=FALSE, what="parsed", config=NULL) {
  name <- if(is.null(name)) random_name() else name
  assert_that(!is.null(name))
  
  if (is.null(ssh_keys)) {
    all_keys <- keys()
    if (length(all_keys) >= 1) {
      message("Using default ssh key: ", all_keys[[1]]$name)
      ssh_keys <- all_keys[[1]]$id
    }
  }

  args <- ct(name=nn(name), size=nn(size), image=nn(image), region=nn(region), 
    ssh_keys=nn(ssh_keys, FALSE), backups=nn(backups), ipv6=nn(ipv6), 
    private_networking=nn(private_networking))
  tmp <- do_POST(what, path='droplets', args=args, parse=TRUE, config=config, 
    encodejson=TRUE)
  
  droplet <- structure(tmp$droplet, class = "droplet")
  message(sprintf("Your Digital Ocean Droplet is almost ready...
  You're being charged %s cents per hour, or $%s per month
  You can delete your droplet with droplets_delete()
  or turn it off, etc., see droplets_*() functions", 
  droplet$size$price_hourly, droplet$size$price_monthly))
  
  droplet
}

random_name <- function() sample(words, size = 1)

#' Reboot a droplet.
#'
#' This method allows you to reboot a droplet. This is the preferred method to use if a server is
#' not responding
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_reboot(x=2376676)
#'
#' droplets() %>% droplets_reboot
#' droplets() %>% droplets_reboot %>% actions
#' }

droplets_reboot <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, path = sprintf('droplets/%s/actions', id), args = ct(type='reboot'), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Power cycle a droplet.
#'
#' This method allows you to power cycle a droplet. This will turn off the droplet and then turn it
#' back on.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_power_cycle(x=2376676)
#'
#' droplets() %>% droplets_power_cycle
#' }

droplets_power_cycle <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, path = sprintf('droplets/%s/actions', id), args=ct(type='power_cycle'), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Shutdown a droplet.
#'
#' This method allows you to shutdown a running droplet. The droplet will remain in your account
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_shutdown(x=2376676)
#'
#' droplets() %>% droplets_shutdown
#' }

droplets_shutdown <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, path = sprintf('droplets/%s/actions', id), args=ct(type='shutdown'), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Power off a droplet.
#'
#' This method allows you to poweroff a running droplet. The droplet will remain in your account.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_power_off(x=2376676)
#'
#' # pipe together operations
#' droplets() %>% droplets_power_off %>% events
#' }

droplets_power_off <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args = ct(type='power_off'), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Power on a droplet.
#'
#' This method allows you to poweron a powered off droplet.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_power_on(x=2376676)
#'
#' # many droplets
#' out <- droplets()
#' droplets_power_on(droplet=out)
#'
#' # from retrieving info on a single droplet
#' out <- droplets(1783835)
#' droplets_power_on(droplet=out)
#'
#' # pipe together operations
#' droplets() %>% droplets_power_on
#' }

droplets_power_on <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, path = sprintf('droplets/%s/actions', id), args = ct(type='power_on'), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Reset a password for a droplet.
#'
#' This method will reset the root password for a droplet. Please be aware that this will reboot
#' the droplet to allow resetting the password.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_password_reset(2376676)
#'
#' droplets() %>% droplets_password_reset %>% events
#' }

droplets_password_reset <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args = ct(type='password_reset'), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Resize a droplet.
#'
#' This method allows you to resize a specific droplet to a different size. This will affect the
#' number of processors and memory allocated to the droplet.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets}
#' @param size (character) Size slug (name) of the image size. See \code{sizes}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_resize(2427664, size='1gb')
#'
#' droplets() %>%
#'    droplets_power_off %>%
#'    droplets_resize(size = '1gb') %>%
#'    events
#' }

droplets_resize <- function(x=NULL, size=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args=ct(type='resize', size=size), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Take a snapshot of a droplet.
#'
#' This method allows you to take a snapshot of the droplet once it has been powered off, which can
#' later be restored or used to create a new droplet from the same image. Please be aware this may
#' cause a reboot.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @param name (character) Optional. Name of the new snapshot you want to create. If not set, the
#' snapshot name will default to date/time
#' @template whatconfig
#' @examples \dontrun{
#' droplets_snapshot(1707487)
#'
#' droplets() %>%
#'  droplets_snapshot %>%
#'  actions
#' }

droplets_snapshot <- function(x=NULL, name=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args=ct(type='snapshot', name=name), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Take a snapshot of a droplet.
#'
#' This method allows you to take a snapshot of the droplet once it has been powered off, which can
#' later be restored or used to create a new droplet from the same image. Please be aware this may
#' cause a reboot.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_snapshots_list(1707487)
#'
#' droplets() %>%
#'  droplets_snapshots_list
#' }

droplets_snapshots_list <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_GET(what, sprintf('droplets/%s/snapshots', id), config=config)
  if(what == 'raw') tmp else parse_to_df(tmp)
}

#' Restore a droplet.
#'
#' This method allows you to restore a droplet with a previous image or snapshot. This will be a
#' mirror copy of the image or snapshot to your droplet. Be sure you have backed up any necessary
#' information prior to restore.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @param image (numeric) The image ID of the backup image that you would like to restore.
#' @template whatconfig
#' @examples \dontrun{
#' droplets_restore(1707487, image=3240036)
#'
#' droplets() %>%
#'  droplets_restore
#' }

droplets_restore <- function(x=NULL, image=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id), !is.null(image))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args=ct(type='restore', image=image), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Rebuild a droplet.
#'
#' This method allows you to reinstall a droplet with a default image. This is useful if you want
#' to start again but retain the same IP address for your droplet.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @param image An image slug or ID. This represents the image that the Droplet will use as a base.
#' @template whatconfig
#' @examples \dontrun{
#' droplets_rebuild(1707487, image=3240036)
#'
#' droplets() %>%
#'  droplets_rebuild
#' }

droplets_rebuild <- function(x=NULL, image=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id), !is.null(image))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args=ct(type='rebuild', image=image), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Delete a droplet.
#'
#' This method deletes one of your droplets - this is irreversible
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @param config Options passed on to httr::GET. Must be named, see examples.
#' @examples \dontrun{
#' droplets_delete(1707487)
#' }
#' \donttest{
#' # Chain operations together
#' drops <- droplets()
#' drops$droplets %>%
#'   droplets_delete
#'
#' # Pipe 'em - 1st, create a new droplet
#' id <- droplets_new(name="newdrop", size_id = 64, image_id = 3240036, region_slug = 'sfo1')
#' id <- droplet$id
#' droplets(id) %>%
#'   droplets_delete %>%
#'   actions
#' }

droplets_delete <- function(x=NULL, config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  do_DELETE(path=sprintf('droplets/%s', id), config=config)
}

#' Rename a droplet.
#'
#' This method renames the droplet to the specified name.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @param name (character) The new name for the droplet
#' @template whatconfig
#' @examples \dontrun{
#' droplets_rename(1707487, name='wadup')
#'
#' droplets() %>%
#'  droplets_rename(name="dropmealine")
#' droplets()  # name has changed
#' }

droplets_rename <- function(x=NULL, name=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id), !is.null(name))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args=ct(type='rename', name=name), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}


#' Change the kernel of a droplet.
#'
#' This method changes the kernel of a droplet to a new kernel ID.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @param kernel (numeric) The ID of the new kernel.
#' @template whatconfig
#' @examples \dontrun{
#' droplets_change_kernel(1707487, kernel=61833229)
#'
#' droplets() %>%
#'  droplets_change_kernel(kernel=61833229)
#' droplets()  # kernel has changed
#' }

droplets_change_kernel <- function(x=NULL, kernel=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id), !is.null(kernel))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args=ct(type='change_kernel', kernel=kernel), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' List all available kernels for a droplet.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_kernels_list(2428384)
#'
#' droplets() %>%
#'  droplets_kernels_list
#' }

droplets_kernels_list <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_GET(what, sprintf('droplets/%s/kernels', id), config=config)
  if(what == 'raw') tmp else parse_to_df(tmp)
}

#' Disable backups for a droplet.
#'
#' This method disables backups for a droplet.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_backups_disable(1707487)
#'
#' droplets() %>%
#'  droplets_backups_disable
#' }

droplets_backups_disable <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args=ct(type='disable_backups'), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' List all available backups for a droplet.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_backups_list(2428384)
#'
#' droplets() %>%
#'  droplets_backups_list
#' }

droplets_backups_list <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_GET(what, sprintf('droplets/%s/backups', id), config=config)
  if(what == 'raw') tmp else parse_to_df(tmp)
}


#' Enable IPv6 networking on an existing droplet (within a region that has IPv6 available).
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_enable_ipv6(1707487)
#'
#' droplets() %>%
#'  droplets_enable_ipv6
#' }

droplets_enable_ipv6 <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args=ct(type='enable_ipv6'), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
}

#' Enable private networking on an existing droplet (within a region that has private
#' networking available).
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @template whatconfig
#' @examples \dontrun{
#' droplets_enable_private_networking(1707487)
#'
#' droplets() %>%
#'  droplets_enable_private_networking
#' }

droplets_enable_private_networking <- function(x=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  tmp <- do_POST(what, sprintf('droplets/%s/actions', id), args=ct(type='enable_private_networking'), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(x, id)
    list(meta=tmp$meta, droplet_ids=id, droplets=droplet_match, actions=parse_to_df(tmp))
  }
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
#'
#' droplets() %>%
#'  droplets_actions
#' }

droplets_actions <- function(x=NULL, actionid=NULL, what="parsed", config=NULL)
{
  if(is.numeric(x)) x <- droplets(x)
  id <- check_droplet(x)
  assert_that(!is.null(id))
  path <- if(is.null(actionid)) sprintf('droplets/%s/actions', id) else sprintf('droplets/%s/actions/%s', id, actionid)
  tmp <- do_GET(what, path = path, config=config)
  if(what == 'raw') tmp else parse_to_df(tmp)
}
