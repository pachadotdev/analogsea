#' Get metadata on all your droplets, or droplets by id
#'
#' @importFrom magrittr %>%
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @template params
#' @examples \dontrun{
#' droplets()
#' library("httr")
#' droplets(config=verbose())
#' droplets(config=timeout(seconds = 2))
#' droplets(config=timeout(seconds = 0.3))
#'
#' # raw output
#' droplets(what="raw")
#' res <- droplets(1746449, what="raw")
#' res$headers
#'
#' # Get info on a single droplet, passing in a list of droplet details
#' drops <- droplets()
#' droplets(droplet=drops$droplets[[1]])
#'
#' # Get info on a single droplet, passing in a numeric droplet id
#' droplets(droplet=1746449)
#' }

droplets <- function(droplet=NULL, what="parsed", page=1, per_page=25, config=NULL)
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
  tmp <- do_GET(what, TRUE, path, query = ct(page=page, per_page=per_page), parse = FALSE, config = config)
  if(what == 'raw'){ tmp } else {
    if ("droplet" %in% names(tmp)){
      names(tmp) <- "droplets"
      ids <- tmp$droplets$id
    } else { ids <- tmp$droplets$id }
    dat <- lapply(tmp$droplets, function(x){
      data.frame(x[c('id','name','memory','vcpus','disk','locked','status','created_at')],
                 region=x$region$slug, region=x$image$name, stringsAsFactors = FALSE)
    })
    dropdf <- do.call(rbind.fill, dat)
    details <- lapply(tmp$droplets, function(y){
      tmp <- y[ !names(y) %in% c('id','name','memory','vcpus','disk','locked','status','created_at') ]
      data.frame(slug=tmp$region$slug, name=tmp$region$name, available=tmp$region$available,
                 sizes=paste(tmp$region$sizes, collapse = ","),
                 features=paste(tmp$region$features, collapse = ","), stringsAsFactors = FALSE)
    })
    details <- do.call(rbind.fill, details)
    list(meta=tmp$meta, droplet_ids = ids, droplets = list(data=dropdf, details=details))
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
#' droplets_new(name="newdrop", size = '512mb', image = 'ubuntu-14-04-x64', region = 'sfo1')
#' }

droplets_new <- function(name=NULL, size=NULL, image=NULL, region=NULL, ssh_keys=NULL, backups=NULL,
  ipv6=NULL, private_networking=FALSE, what="parsed", config=NULL)
{
  assert_that(!is.null(name))
  args <- ct(name=name, size=size, image=image, region=region, ssh_keys=ssh_keys,
             backups=backups, ipv6=ipv6, private_networking=private_networking)
  do_POST(what, path='droplets', args=args, parse=TRUE, config=config)
}

do_POST <- function(what, path, args, parse=FALSE, config=config) {
  url <- file.path("https://api.digitalocean.com/v2", path)
  au <- do_get_auth()
  auth <- add_headers(Authorization = sprintf('Bearer %s', au$token))

  tt <- POST(url, config = c(auth, config=NULL), body=args)
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(content(tt)$message)
    if(content(tt)$status == "ERROR") stop(content(tt)$message)
  }
  if(what=='parsed'){
    res <- content(tt, as = "text")
    jsonlite::fromJSON(res, parse)
  } else { tt }
}

#' Reboot a droplet.
#'
#' This method allows you to reboot a droplet. This is the preferred method to use if a server is
#' not responding
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @template params
#' @examples \dontrun{
#' droplets_reboot(id=1739894)
#'
#' droplets() %>% droplets_reboot
#' droplets() %>% droplets_reboot %>% events
#' }

droplets_reboot <- function(droplet=NULL, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/reboot', id), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id)
  }
}

#' Power cycle a droplet.
#'
#' This method allows you to power cycle a droplet. This will turn off the droplet and then turn it
#' back on
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @template params
#' @examples \dontrun{
#' droplets_power_cycle(id=1739894)
#'
#' droplets() %>% droplets_power_cycle
#' }

droplets_power_cycle <- function(droplet=NULL, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/power_cycle', id), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id)
  }
}

#' Shutdown a droplet.
#'
#' This method allows you to shutdown a running droplet. The droplet will remain in your account
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @template params
#' @examples \dontrun{
#' droplets_shutdown(id=1707487)
#'
#' droplets() %>% droplets_shutdown
#' }

droplets_shutdown <- function(droplet=NULL, what="parsed", config=config)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/shutdown', id), config=NULL)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id)
  }
}

#' Power off a droplet.
#'
#' This method allows you to poweroff a running droplet. The droplet will remain in your account.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @template params
#' @examples \dontrun{
#' droplets_power_off(id=1739894)
#'
#' # pipe together operations
#' droplets() %>% droplets_power_off %>% events
#' }

droplets_power_off <- function(droplet=NULL, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/power_off', id), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id)
  }
}

# droptesting(droplets(1880805))
#
# droptesting <- function(droplet=NULL, what="parsed", config=NULL)
# {
#   id <- check_droplet(droplet)
#   id
# }

#' Power on a droplet.
#'
#' This method allows you to poweron a powered off droplet.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @template params
#' @examples \dontrun{
#' droplets_power_on(id=1739894)
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

droplets_power_on <- function(droplet=NULL, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/power_on', id), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id)
  }
}

#' Reset a password for a droplet.
#'
#' This method will reset the root password for a droplet. Please be aware that this will reboot
#' the droplet to allow resetting the password.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @template params
#' @examples \dontrun{
#' droplets_password_reset(id=1707487)
#'
#' droplets() %>% droplets_password_reset %>% events
#' }

droplets_password_reset <- function(droplet=NULL, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/password_reset', id), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id)
  }
}

#' Resize a droplet.
#'
#' This method allows you to resize a specific droplet to a different size. This will affect the
#' number of processors and memory allocated to the droplet.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @param size_id (numeric) Size id of the image size
#' @param size_slug (character) Size slug (name) of the image size
#' @template params
#' @examples \dontrun{
#' droplets_resize(id=1707487, size_id=63)
#'
#' droplets() %>%
#'    droplets_power_off %>%
#'    droplets_resize(size_id = 62) %>%
#'    events
#' }

droplets_resize <- function(droplet=NULL, size_id=NULL, size_slug=NULL, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  assert_that(xor(is.null(size_id), is.null(size_slug)))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/resize', id), ct(size_id=size_id, size_slug=size_slug), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
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
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @param name (character) Optional. Name of the new snapshot you want to create. If not set, the
#' snapshot name will default to date/time
#' @template params
#' @examples \dontrun{
#' droplets_snapshot(id=1707487)
#'
#' droplets() %>%
#'  droplets_snapshot %>%
#'  events
#' }

droplets_snapshot <- function(droplet=NULL, name=NULL, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/snapshot', id), ct(name=name), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
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
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @param image_id The image id to use to rebuild the droplet.
#' @template params
#' @examples \dontrun{
#' droplets_restore(id=1707487, image_id=3240036)
#'
#' droplets() %>%
#'  droplets_restore
#' }

droplets_restore <- function(droplet=NULL, image_id=NULL, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id), !is.null(image_id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/restore', id), ct(image_id=image_id), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id)
  }
}

#' Rebuild a droplet.
#'
#' This method allows you to reinstall a droplet with a default image. This is useful if you want
#' to start again but retain the same IP address for your droplet.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @param image_id The image id to use to rebuild the droplet.
#' @template params
#' @examples \dontrun{
#' droplets_rebuild(id=1707487, image_id=3240036)
#'
#' droplets() %>%
#'  droplets_rebuild
#' }

droplets_rebuild <- function(droplet=NULL, image_id=NULL, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id), !is.null(image_id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/rebuild', id), ct(image_id=image_id), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id)
  }
}

#' Destory a droplet.
#'
#' This method destroys one of your droplets - this is irreversible
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @param scrub_data (logical) To scrub data or not
#' @template params
#' @examples \dontrun{
#' droplets_destroy(id=1707487)
#' }
#' \donttest{
#' # Chain operations together - FUTURE, shut off multiple droplets
#' drops <- droplets()
#' drops$droplets %>% droplets_destroy
#'
#' # Pipe 'em - 1st, create a new droplet
#' id <- droplets_new(name="newdrop", size_id = 64, image_id = 3240036, region_slug = 'sfo1')
#' id <- droplet$id
#' droplets(id) %>% droplets_destroy %>% events
#' }

droplets_destroy <- function(droplet=NULL, scrub_data=FALSE, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/destroy', id), ct(scrub_data=scrub_data), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id)
  }
}

#' Rename a droplet.
#'
#' This method renames the droplet to the specified name.
#'
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @param name (character) Name of the droplet
#' @template params
#' @examples \dontrun{
#' droplets_rename(id=1707487, name='wadup')
#'
#' droplets() %>%
#'  droplets_rename(name="dropmealine")
#' droplets()  # name has changed
#' }

droplets_rename <- function(droplet=NULL, name=NULL, what="parsed", config=NULL)
{
  id <- check_droplet(droplet)
  assert_that(!is.null(id), !is.null(name))
  tmp <- do_GET(what, TRUE, sprintf('droplets/%s/rename', id), ct(name=name), config=config)
  if(what == 'raw'){ tmp } else {
    droplet_match <- match_droplet(droplet)
    list(droplet_ids=id, droplets=droplet_match, event_id=tmp$event_id)
  }
}
