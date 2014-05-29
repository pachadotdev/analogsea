#' Get metadata on all your droplets, or droplets by id
#'
#' @export
#' @template id
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_get()
#' droplets_get(config=verbose())
#' droplets_get(config=timeout(seconds = 0.3))
#' droplets_get(config=timeout(seconds = 0.3))
#' # raw output
#' droplets_get(what="raw")
#' }

droplets_get <- function(id=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  path <- if(is.null(id)) 'droplets' else sprintf('droplets/%s', id)
  do_handle(what, path, ...)
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
#' do_auth()
#' droplets_new(name="newdrop", size_id = 64, image_id = 3240036, region_slug = 'sfo1')
#' }

droplets_new <- function(name=NULL, size_id=NULL, size_slug=NULL, image_id=NULL, image_slug=NULL,
  region_id=NULL, region_slug=NULL, ssh_key_ids=NULL, private_networking=FALSE,
  backups_enable=FALSE, what="parsed", ...)
{
  au <- do_get_auth()

  assert_that(!is.null(name))
  assert_that(xor(is.null(size_id), is.null(size_slug)))
  assert_that(xor(is.null(image_id), is.null(image_slug)))
  assert_that(xor(is.null(region_id), is.null(region_slug)))
  args <- ct(name=name, size_id=size_id, size_slug=size_slug,
    image_id=image_id,image_slug=image_slug, region_id=region_id,
    region_slug=region_slug,ssh_key_ids=ssh_key_ids, private_networking=private_networking,
    backups_enable=backups_enable,client_id=au$id, api_key=au$key)
  do_handle(what, 'droplets/new', args, ...)
}

#' Reboot a droplet.
#'
#' This method allows you to reboot a droplet. This is the preferred method to use if a server is
#' not responding
#'
#' @export
#' @template id
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_reboot(id=1739894)
#' }

droplets_reboot <- function(id=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id))
  do_handle(what, sprintf('droplets/%s/reboot', id), ...)
}

#' Power cycle a droplet.
#'
#' This method allows you to power cycle a droplet. This will turn off the droplet and then turn it
#' back on
#'
#' @export
#' @template id
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_power_cycle(id=1739894)
#' }

droplets_power_cycle <- function(id=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id))
  do_handle(what, sprintf('droplets/%s/power_cycle', id), ...)
}

#' Shutdown a droplet.
#'
#' This method allows you to shutdown a running droplet. The droplet will remain in your account
#'
#' @export
#' @template id
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_shutdown(id=1707487)
#' }

droplets_shutdown <- function(id=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id))
  do_handle(what, sprintf('droplets/%s/shutdown', id), ...)
}

#' Power off a droplet.
#'
#' This method allows you to poweroff a running droplet. The droplet will remain in your account.
#'
#' @export
#' @template id
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_power_off(id=1739894)
#' }

droplets_power_off <- function(id=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id))
  do_handle(what, sprintf('droplets/%s/power_off', id), ...)
}

#' Power on a droplet.
#'
#' This method allows you to poweron a powered off droplet.
#'
#' @export
#' @template id
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_power_on(id=1739894)
#' }

droplets_power_on <- function(id=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id))
  do_handle(what, sprintf('droplets/%s/power_on', id), ...)
}


#' Reset a password for a droplet.
#'
#' This method will reset the root password for a droplet. Please be aware that this will reboot
#' the droplet to allow resetting the password.
#'
#' @export
#' @template id
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_password_reset(id=1707487)
#' }

droplets_password_reset <- function(id=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id))
  do_handle(what, sprintf('droplets/%s/password_reset', id), ...)
}

#' Resize a droplet.
#'
#' This method allows you to resize a specific droplet to a different size. This will affect the
#' number of processors and memory allocated to the droplet.
#'
#' @export
#' @template id
#' @param size_id (numeric) Size id of the image size
#' @param size_slug (character) Size slug (name) of the image size
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_resize(id=1707487, size_id=66)
#' }

droplets_resize <- function(id=NULL, size_id=NULL, size_slug=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id))
  assert_that(xor(is.null(size_id), is.null(size_slug)))
  do_handle(what, sprintf('droplets/%s/resize', id), ct(size_id=size_id, size_slug=size_slug), ...)
}

#' Take a snapshot of a droplet.
#'
#' This method allows you to take a snapshot of the droplet once it has been powered off, which can
#' later be restored or used to create a new droplet from the same image. Please be aware this may
#' cause a reboot.
#'
#' @export
#' @template id
#' @param name (character) Name of the droplet
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_snapshot(id=1707487)
#' }

droplets_snapshot <- function(id=NULL, name=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id))
  do_handle(what, sprintf('droplets/%s/snapshot', id), ct(name=name), ...)
}

#' Restore a droplet.
#'
#' This method allows you to take a snapshot of the droplet once it has been powered off, which can
#' later be restored or used to create a new droplet from the same image. Please be aware this may
#' cause a reboot.
#'
#' @export
#' @template id
#' @param image_id The image id to use to rebuild the droplet.
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_restore(id=1707487, image_id=3240036)
#' }

droplets_restore <- function(id=NULL, image_id=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id), !is.null(image_id))
  do_handle(what, sprintf('droplets/%s/restore', id), ct(image_id=image_id), ...)
}

#' Rebuild a droplet.
#'
#' This method allows you to reinstall a droplet with a default image. This is useful if you want to
#' start again but retain the same IP address for your droplet.
#'
#' @export
#' @template id
#' @param image_id The image id to use to rebuild the droplet.
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_rebuild(id=1707487, image_id=3240036)
#' }

droplets_rebuild <- function(id=NULL, image_id=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id), !is.null(image_id))
  do_handle(what, sprintf('droplets/%s/rebuild', id), ct(image_id=image_id), ...)
}

#' Destory a droplet.
#'
#' This method destroys one of your droplets - this is irreversible
#'
#' @export
#' @template id
#' @param scrub_data (logical) To scrub data or not
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_destroy(id=1707487)
#' }

droplets_destroy <- function(id=NULL, scrub_data=FALSE, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id))
  do_handle(what, sprintf('droplets/%s/destroy', id), ct(scrub_data=scrub_data), ...)
}

#' Rename a droplet.
#'
#' This method renames the droplet to the specified name.
#'
#' @export
#' @template id
#' @param name (character) Name of the droplet
#' @template params
#' @examples \dontrun{
#' do_auth()
#' droplets_rename(id=1707487, name='wadup')
#' }

droplets_rename <- function(id=NULL, name=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  assert_that(!is.null(id), !is.null(name))
  do_handle(what, sprintf('droplets/%s/rename', id), ct(name=name), ...)
}
