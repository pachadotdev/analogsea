#' Get metadata on all your droplets, or droplets by id
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_get()
#' # raw output
#' do_droplets_get(what="raw")
#' }

do_droplets_get <- function(id=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()
  if(is.null(id)){
    url <- 'https://api.digitalocean.com/v1/droplets'
  } else {
    url <- sprintf('https://api.digitalocean.com/v1/droplets/%s', id)
  }
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
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
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_new(name="newdrop", size_id = 64, image_id = 3240036, region_slug = 'sfo1')
#' }

do_droplets_new <- function(name=NULL, size_id=NULL, size_slug=NULL, image_id=NULL, image_slug=NULL,
  region_id=NULL, region_slug=NULL, ssh_key_ids=NULL, private_networking=FALSE,
  backups_enable=FALSE, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(name))
  assert_that(xor(is.null(size_id), is.null(size_slug)))
  assert_that(xor(is.null(image_id), is.null(image_slug)))
  assert_that(xor(is.null(region_id), is.null(region_slug)))

  url <- 'https://api.digitalocean.com/v1/droplets/new'
  args <- do_compact(list(name=name, size_id=size_id, size_slug=size_slug, image_id=image_id,
                       image_slug=image_slug, region_id=region_id, region_slug=region_slug,
                       ssh_key_ids=ssh_key_ids, private_networking=private_networking,
                       backups_enable=backups_enable,client_id=au$id, api_key=au$key))
  out <- do_handle(what, url, args, callopts)
  class(out) <- "dodroplet"
  return( out )
}

#' Reboot a droplet.
#'
#' This method allows you to reboot a droplet. This is the preferred method to use if a server is
#' not responding
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_reboot(id=1707487)
#' }

do_droplets_reboot <- function(id=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/reboot', id)
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}

#' Power cycle a droplet.
#'
#' This method allows you to power cycle a droplet. This will turn off the droplet and then turn it back on
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_power_cycle(id=1707487)
#' }

do_droplets_power_cycle <- function(id=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/power_cycle', id)
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}

#' Shutdown a droplet.
#'
#' This method allows you to shutdown a running droplet. The droplet will remain in your account
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_shutdown(id=1707487)
#' }

do_droplets_shutdown <- function(id=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/shutdown', id)
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}

#' Power off a droplet.
#'
#' This method allows you to poweroff a running droplet. The droplet will remain in your account.
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_power_off(id=1707487)
#' }

do_droplets_power_off <- function(id=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/power_off', id)
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}

#' Power on a droplet.
#'
#' This method allows you to poweron a powered off droplet.
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_power_on(id=1707487)
#' }

do_droplets_power_on <- function(id=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/power_on', id)
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}


#' Reset a password for a droplet.
#'
#' This method will reset the root password for a droplet. Please be aware that this will reboot
#' the droplet to allow resetting the password.
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_password_reset(id=1707487)
#' }

do_droplets_password_reset <- function(id=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/password_reset', id)
  args <- do_compact(list(client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}

#' Resize a droplet.
#'
#' This method allows you to resize a specific droplet to a different size. This will affect the
#' number of processors and memory allocated to the droplet.
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param size_id (numeric) Size id of the image size
#' @param size_slug (character) Size slug (name) of the image size
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_resize(id=1707487)
#' }

do_droplets_resize <- function(id=NULL, size_id=NULL, size_slug=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  assert_that(xor(is.null(size_id), is.null(size_slug)))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/resize', id)
  args <- do_compact(list(size_id=size_id, size_slug=size_slug, client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}

#' Take a snapshot of a droplet.
#'
#' This method allows you to take a snapshot of the droplet once it has been powered off, which can
#' later be restored or used to create a new droplet from the same image. Please be aware this may
#' cause a reboot.
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param name (character) Name of the droplet
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_snapshot(id=1707487)
#' }

do_droplets_snapshot <- function(id=NULL, name=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/snapshot', id)
  args <- do_compact(list(name=name, client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}


#' Restore a droplet.
#'
#' This method allows you to take a snapshot of the droplet once it has been powered off, which can
#' later be restored or used to create a new droplet from the same image. Please be aware this may
#' cause a reboot.
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param image_id The image id to use to rebuild the droplet.
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_restore(id=1707487, image_id=3240036)
#' }

do_droplets_restore <- function(id=NULL, image_id=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  assert_that(!is.null(image_id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/restore', id)
  args <- do_compact(list(image_id=image_id, client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}


#' Rebuild a droplet.
#'
#' This method allows you to reinstall a droplet with a default image. This is useful if you want to
#' start again but retain the same IP address for your droplet.
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param image_id The image id to use to rebuild the droplet.
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_rebuild(id=1707487, image_id=3240036)
#' }

do_droplets_rebuild <- function(id=NULL, image_id=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  assert_that(!is.null(image_id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/rebuild', id)
  args <- do_compact(list(image_id=image_id, client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}


#' Destory a droplet.
#'
#' This method destroys one of your droplets - this is irreversible
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param scrub_data (logical) To scrub data or not
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_destroy(id=1707487)
#' }

do_droplets_destroy <- function(id=NULL, scrub_data=FALSE, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/destroy', id)
  args <- do_compact(list(scrub_data=scrub_data, client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}


#' Rename a droplet.
#'
#' This method renames the droplet to the specified name.
#'
#' @export
#' @param id (numeric) A droplet id (optional)
#' @param name (character) Name of the droplet
#' @param what (character) One of list or raw
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' do_auth()
#' do_droplets_rename(id=1707487, name='wadup')
#' }

do_droplets_rename <- function(id=NULL, name=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()

  assert_that(!is.null(id))
  assert_that(!is.null(name))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/rename', id)
  args <- do_compact(list(name=name, client_id=au$id, api_key=au$key))
  do_handle(what, url, args, callopts)
}
