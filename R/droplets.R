#' Get metadata on all your droplets, or droplets by id
#'
#' @importFrom magrittr %>%
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @template params
#' @examples \dontrun{
#' droplets_get()
#' droplets_get(config=verbose())
#' droplets_get(config=timeout(seconds = 0.3))
#' 
#' # raw output
#' droplets_get(what="raw")
#' res <- droplets_get(1746449, what="raw")
#' res$headers
#' 
#' # Get info on a single droplet, passing in a list of droplet details
#' drops <- droplets_get()
#' droplets_get(droplet=drops$droplets[[1]])
#' 
#' # Get info on a single droplet, passing in a numeric droplet id
#' droplets_get(droplet=1746449)
#' }

droplets_get <- function(droplet=NULL, what="parsed", ...)
{
  if(!is.null(droplet)){
    if(is.list(droplet)){
      if(!is.numeric(droplet$id)) stop("Could not detect a droplet id")
    } else {
      if(!is.numeric(as.numeric(as.character(droplet)))) stop("Could not detect a droplet id")
    }
    id <- if(is.numeric(droplet)) droplet else droplet$id 
  } else { id <- NULL }
  path <- if(is.null(droplet)) 'droplets' else sprintf('droplets/%s', id)
  tmp <- do_GET(what, TRUE, path, ...)
  if(what == 'raw'){ tmp } else {
    if ("droplet" %in% names(tmp)){
      names(tmp) <- "droplets"
      ids <- tmp$droplets$id
    } else { ids <- sapply(tmp$droplets, "[[", "id") }
    list(droplet_ids = ids, droplets = tmp$droplets, event_id=NULL)
  }
}

#' Create a new droplet.
#'
#' @export
#' @param name (character) Name of the droplet
#' @param size_id (logical) Size id. Use one of size_id or size_slug, not both
#' @param size_slug (character) Size slug
#' @param image_id (logical) Image id. Use one of image_id or image_slug, not both
#' @param image_slug (character) Image slug
#' @param region_id (logical) Region id. Use one of region_id or region_slug, not both
#' @param region_slug (character) Region slug.
#' @param ssh_key_ids (logical) Vector of ssh keys.
#' @param private_networking (logical) Use private networking, default FALSE.
#' @param backups_enable (logical) Enable backups
#' @template params
#' @examples \dontrun{
#' droplets_new(name="newdrop", size_id = 64, image_id = 3240036, region_slug = 'sfo1')
#' }

droplets_new <- function(name=NULL, size_id=NULL, size_slug=NULL, image_id=NULL, image_slug=NULL,
  region_id=NULL, region_slug=NULL, ssh_key_ids=NULL, private_networking=FALSE,
  backups_enable=FALSE, what="parsed", ...)
{
  assert_that(!is.null(name))
  assert_that(xor(is.null(size_id), is.null(size_slug)))
  assert_that(xor(is.null(image_id), is.null(image_slug)))
  assert_that(xor(is.null(region_id), is.null(region_slug)))
  args <- ct(name=name, size_id=size_id, size_slug=size_slug,
    image_id=image_id,image_slug=image_slug, region_id=region_id,
    region_slug=region_slug,ssh_key_ids=ssh_key_ids, private_networking=private_networking,
    backups_enable=backups_enable)
  do_GET(what, TRUE, 'droplets/new', args, ...)
}

#' Reboot a droplet.
#'
#' This method allows you to reboot a droplet. This is the preferred method to use if a server is
#' not responding
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @template params
#' @examples \dontrun{
#' droplets_reboot(id=1739894)
#' 
#' droplets_get() %>% droplets_reboot
#' droplets_get() %>% droplets_reboot %>% events
#' }

droplets_reboot <- function(droplet=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/reboot', id), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Power cycle a droplet.
#'
#' This method allows you to power cycle a droplet. This will turn off the droplet and then turn it
#' back on
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @template params
#' @examples \dontrun{
#' droplets_power_cycle(id=1739894)
#' 
#' droplets_get() %>% droplets_power_cycle
#' }

droplets_power_cycle <- function(droplet=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/power_cycle', id), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Shutdown a droplet.
#'
#' This method allows you to shutdown a running droplet. The droplet will remain in your account
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @template params
#' @examples \dontrun{
#' droplets_shutdown(id=1707487)
#' 
#' droplets_get() %>% droplets_shutdown
#' }

droplets_shutdown <- function(droplet=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/shutdown', id), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Power off a droplet.
#'
#' This method allows you to poweroff a running droplet. The droplet will remain in your account.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @template params
#' @examples \dontrun{
#' droplets_power_off(id=1739894)
#' 
#' # pipe together operations
#' droplets_get() %>% droplets_power_off %>% events
#' }

droplets_power_off <- function(droplet=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/power_off', id), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Power on a droplet.
#'
#' This method allows you to poweron a powered off droplet.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @template params
#' @examples \dontrun{
#' droplets_power_on(id=1739894)
#' 
#' # many droplets
#' out <- droplets_get()
#' droplets_power_on(droplet=out)
#' 
#' # from retrieving info on a single droplet
#' out <- droplets_get(1783835)
#' droplets_power_on(droplet=out)
#' 
#' # pipe together operations
#' droplets_get() %>% droplets_power_on
#' }

droplets_power_on <- function(droplet=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/power_on', id), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Reset a password for a droplet.
#'
#' This method will reset the root password for a droplet. Please be aware that this will reboot
#' the droplet to allow resetting the password.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @template params
#' @examples \dontrun{
#' droplets_password_reset(id=1707487)
#' 
#' droplets_get() %>% droplets_password_reset %>% events
#' }

droplets_password_reset <- function(droplet=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/password_reset', id), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Resize a droplet.
#'
#' This method allows you to resize a specific droplet to a different size. This will affect the
#' number of processors and memory allocated to the droplet.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @param size_id (numeric) Size id of the image size
#' @param size_slug (character) Size slug (name) of the image size
#' @template params
#' @examples \dontrun{
#' droplets_resize(id=1707487, size_id=63)
#' 
#' droplets_get() %>%
#'    droplets_power_off %>%
#'    droplets_resize(size_id = 62) %>% 
#'    events
#' }

droplets_resize <- function(droplet=NULL, size_id=NULL, size_slug=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  assert_that(xor(is.null(size_id), is.null(size_slug)))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/resize', id), ct(size_id=size_id, size_slug=size_slug), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Take a snapshot of a droplet.
#'
#' This method allows you to take a snapshot of the droplet once it has been powered off, which can
#' later be restored or used to create a new droplet from the same image. Please be aware this may
#' cause a reboot.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @param name (character) Optional. Name of the new snapshot you want to create. If not set, the 
#' snapshot name will default to date/time
#' @template params
#' @examples \dontrun{
#' droplets_snapshot(id=1707487)
#' 
#' droplets_get() %>% 
#'  droplets_snapshot %>% 
#'  events
#' }

droplets_snapshot <- function(droplet=NULL, name=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/snapshot', id), ct(name=name), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Restore a droplet.
#'
#' This method allows you to restore a droplet with a previous image or snapshot. This will be a 
#' mirror copy of the image or snapshot to your droplet. Be sure you have backed up any necessary
#' information prior to restore.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @param image_id The image id to use to rebuild the droplet.
#' @template params
#' @examples \dontrun{
#' droplets_restore(id=1707487, image_id=3240036)
#' 
#' droplets_get() %>% 
#'  droplets_restore
#' }

droplets_restore <- function(droplet=NULL, image_id=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id), !is.null(image_id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/restore', id), ct(image_id=image_id), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Rebuild a droplet.
#'
#' This method allows you to reinstall a droplet with a default image. This is useful if you want
#' to start again but retain the same IP address for your droplet.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @param image_id The image id to use to rebuild the droplet.
#' @template params
#' @examples \dontrun{
#' droplets_rebuild(id=1707487, image_id=3240036)
#' 
#' droplets_get() %>%
#'  droplets_rebuild
#' }

droplets_rebuild <- function(droplet=NULL, image_id=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id), !is.null(image_id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/rebuild', id), ct(image_id=image_id), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Destory a droplet.
#'
#' This method destroys one of your droplets - this is irreversible
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @param scrub_data (logical) To scrub data or not
#' @template params
#' @examples \dontrun{
#' droplets_destroy(id=1707487)
#' }
#' \donttest{
#' # Chain operations together - FUTURE, shut off multiple droplets
#' drops <- droplets_get()
#' drops$droplets %>% droplets_destroy
#' 
#' # Pipe 'em - 1st, create a new droplet
#' id <- droplets_new(name="newdrop", size_id = 64, image_id = 3240036, region_slug = 'sfo1')
#' id <- droplet$id
#' droplets_get(id) %>% droplets_destroy %>% events
#' }

droplets_destroy <- function(droplet=NULL, scrub_data=FALSE, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/destroy', id), ct(scrub_data=scrub_data), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}

#' Rename a droplet.
#'
#' This method renames the droplet to the specified name.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets_get()}
#' @param name (character) Name of the droplet
#' @template params
#' @examples \dontrun{
#' droplets_rename(id=1707487, name='wadup')
#' 
#' droplets_get() %>%
#'  droplets_rename(name="dropmealine")
#' droplets_get()  # name has changed
#' }

droplets_rename <- function(droplet=NULL, name=NULL, what="parsed", ...)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id), !is.null(name))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/rename', id), ct(name=name), ...)
  if(what == 'raw'){ tmp } else {
    droplet_match <- droplet$droplets[vapply(droplet$droplets, "[[", 1, "id")==id]
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id) 
  }
}