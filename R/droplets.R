#' Get metadata on all your droplets, or droplets by id
#'
#' @import httr jsonlite plyr
#' @export
#' @param auth Authentication object, of class doauth
#' 
#' @examples \dontrun{
#' auth <- do_auth()
#' do_droplets_get(auth)
#' do_droplets_get(id=1707487, client_id='dfadeb9dc1b68d93119f886f8aa36393', api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')
#' # raw output
#' do_droplets_get(client_id='dfadeb9dc1b68d93119f886f8aa36393',
#'             api_key='16ff41ec1f6a4ec6d3f0107f639a59b7', what="raw")
#' }

do_droplets_get <- function(auth, id=NULL, what="list", callopts=list())
{
  if(is.null(id)){
    url <- 'https://api.digitalocean.com/v1/droplets'
  } else {
    url <- sprintf('https://api.digitalocean.com/v1/droplets/%s', id)
  }
  args <- compact(list(client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}


#####
do_droplets_new(name="newdrop", size_id = 64, image_id = 3240036, region_slug = 'sfo1',
                client_id='dfadeb9dc1b68d93119f886f8aa36393', api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_new <- function(name=NULL, size_id=NULL, size_slug=NULL, image_id=NULL, image_slug=NULL,
  region_id=NULL, region_slug=NULL, ssh_key_ids=NULL, private_networking=FALSE,
  backups_enable=FALSE, client_id=NULL, api_key=NULL, what="list", callopts=list())
{
  assert_that(!is.null(name))
  assert_that(xor(is.null(size_id), is.null(size_slug)))
  assert_that(xor(is.null(image_id), is.null(image_slug)))
  assert_that(xor(is.null(region_id), is.null(region_slug)))

  url <- 'https://api.digitalocean.com/v1/droplets/new'
  args <- compact(list(name=name, size_id=size_id, size_slug=size_slug, image_id=image_id,
                       image_slug=image_slug, region_id=region_id, region_slug=region_slug,
                       ssh_key_ids=ssh_key_ids, private_networking=private_networking,
                       backups_enable=backups_enable,client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}

######
# Reboot Droplet
# This method allows you to reboot a droplet. This is the preferred method to use if a server is not responding
do_droplets_reboot(id=1707487, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_reboot <- function(id=NULL, client_id=NULL, api_key=NULL, what="list", callopts=list())
{
  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/reboot', id)
  args <- compact(list(client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}

######
# Power cycle Droplet
# This method allows you to power cycle a droplet. This will turn off the droplet and then turn it back on
do_droplets_power_cycle(id=1707487, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                   api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_power_cycle <- function(id=NULL, client_id=NULL, api_key=NULL, what="list", callopts=list())
{
  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/power_cycle', id)
  args <- compact(list(client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}

######
# Shutdown Droplet
# This method allows you to shutdown a running droplet. The droplet will remain in your account
do_droplets_shutdown(id=1707487, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                        api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_shutdown <- function(id=NULL, client_id=NULL, api_key=NULL, what="list", callopts=list())
{
  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/shutdown', id)
  args <- compact(list(client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}

######
# Power off Droplet
# This method allows you to poweroff a running droplet. The droplet will remain in your account.
do_droplets_power_off(id=1707487, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                     api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_power_off <- function(id=NULL, client_id=NULL, api_key=NULL, what="list", callopts=list())
{
  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/power_off', id)
  args <- compact(list(client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}

######
# Power on Droplet
# This method allows you to poweron a powered off droplet.
do_droplets_power_on(id=1707487, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                      api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_power_on <- function(id=NULL, client_id=NULL, api_key=NULL, what="list", callopts=list())
{
  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/power_on', id)
  args <- compact(list(client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}


######
# Reset Root Password
# This method will reset the root password for a droplet. Please be aware that this will reboot
# the droplet to allow resetting the password.
do_droplets_password_reset(id=1707487, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                     api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_password_reset <- function(id=NULL, client_id=NULL, api_key=NULL, what="list", callopts=list())
{
  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/password_reset', id)
  args <- compact(list(client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}

######
# Resize droplet
# This method allows you to resize a specific droplet to a different size. This will affect the
# number of processors and memory allocated to the droplet.
do_droplets_resize(id=1707487, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                           api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_resize <- function(id=NULL, size_id=NULL, size_slug=NULL, client_id=NULL, api_key=NULL,
                               what="list", callopts=list())
{
  assert_that(!is.null(id))
  assert_that(xor(is.null(size_id), is.null(size_slug)))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/resize', id)
  args <- compact(list(size_id=size_id, size_slug=size_slug, client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}

######
# Take a snapshot of a droplet
# This method allows you to take a snapshot of the droplet once it has been powered off, which can
# later be restored or used to create a new droplet from the same image. Please be aware this may
# cause a reboot.
do_droplets_snapshot(id=1707487, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                   api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_snapshot <- function(id=NULL, name=NULL, client_id=NULL, api_key=NULL,
                               what="list", callopts=list())
{
  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/snapshot', id)
  args <- compact(list(name=name, client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}


######
# Restore droplet
# This method allows you to take a snapshot of the droplet once it has been powered off, which can
# later be restored or used to create a new droplet from the same image. Please be aware this may
# cause a reboot.
do_droplets_restore(id=1707487, image_id=3240036, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                     api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_restore <- function(id=NULL, image_id=NULL, client_id=NULL, api_key=NULL,
                                 what="list", callopts=list())
{
  assert_that(!is.null(id))
  assert_that(!is.null(image_id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/restore', id)
  args <- compact(list(image_id=image_id, client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}


######
# Rebuild droplet
# This method allows you to reinstall a droplet with a default image. This is useful if you want to
# start again but retain the same IP address for your droplet.
do_droplets_rebuild(id=1707487, image_id=3240036, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                    api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_rebuild <- function(id=NULL, image_id=NULL, client_id=NULL, api_key=NULL,
                                what="list", callopts=list())
{
  assert_that(!is.null(id))
  assert_that(!is.null(image_id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/rebuild', id)
  args <- compact(list(image_id=image_id, client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}


######
# Destroy droplet
# This method destroys one of your droplets - this is irreversible
do_droplets_destroy(id=1707487, client_id='dfadeb9dc1b68d93119f886f8aa36393',
                    api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_destroy <- function(id=NULL, scrub_data=FALSE, client_id=NULL, api_key=NULL,
                                what="list", callopts=list())
{
  assert_that(!is.null(id))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/destroy', id)
  args <- compact(list(scrub_data=scrub_data, client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}


######
# Rename droplet
# This method renames the droplet to the specified name.
do_droplets_rename(id=1707487, name='wadup', client_id='dfadeb9dc1b68d93119f886f8aa36393',
                   api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_droplets_rename <- function(id=NULL, name=NULL, client_id=NULL, api_key=NULL,
                               what="list", callopts=list())
{
  assert_that(!is.null(id))
  assert_that(!is.null(name))
  url <- sprintf('https://api.digitalocean.com/v1/droplets/%s/rename', id)
  args <- compact(list(name=name, client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}
