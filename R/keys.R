#' List your ssh keys, or get a single key
#'
#' @export
#' @param key (numeric/character) An ssh key id (e.g., 3), or key fingerprint 
#' (e.g., c8:6f:72:7e:2f:5b:21:38:2d:9a:0b:ef:0f:75:c8:2d). If none given, 
#' all your keys are listed. (optional)
#' @template params
#' @examples \dontrun{
#' keys()
#' keys(89103)
#' keys("6b:2e:f6:be:e7:b4:58:0e:2a:a0:23:7e:16:ac:fc:17")
#' }

keys <- function(key=NULL, what="parsed", page=1, per_page=25, config=NULL)
{
  path <- if(is.null(key)) 'account/keys' else sprintf('account/keys/%s', key)
  do_GET(what, path=path, parse=FALSE, query = ct(page=page, per_page=per_page), config=config)
}

#' Create a new ssh key.
#'
#' @export
#' @param name (character) Required. The name to give the new SSH key in your account.
#' @param public_key (character) Required. A string containing the entire public key.
#' @template whatconfig
#' @examples \donttest{
#' keys_create(name="newkey", "ssh-rsa AB34....")
#' }

keys_create <- function(name=NULL, public_key=NULL, what="parsed", config=NULL)
{
  assert_that(!is.null(name), !is.null(public_key))
  do_POST(what, path='account/keys', parse=TRUE, 
                args = ct(name=name, public_key=public_key), config=config)
}

#' Update one of your ssh keys.
#'
#' @export
#' @param name (character) Required. The name to give the new SSH key in your account.
#' @param key (numeric/character) An ssh key id (e.g., 3), or key fingerprint 
#' (e.g., c8:6f:72:7e:2f:5b:21:38:2d:9a:0b:ef:0f:75:c8:2d). If none given, 
#' all your keys are listed. (optional)
#' @template whatconfig
#' @examples \donttest{
#' keys_rename(name="newkey", key=89103)
#' }

keys_rename <- function(name=NULL, key=NULL, what="parsed", config=NULL)
{
  assert_that(!is.null(name), !is.null(key))
  do_PUT(what, path=sprintf('account/keys/%s', key), parse=TRUE, args = ct(name=name), config=config)
}

#' Permanently delete/destroy one of your ssh keys.
#'
#' @export
#' @param key (numeric/character) An ssh key id (e.g., 3), or key fingerprint 
#' (e.g., c8:6f:72:7e:2f:5b:21:38:2d:9a:0b:ef:0f:75:c8:2d). If none given, 
#' all your keys are listed. (optional)
#' @param config Options passed on to httr::GET. Must be named, see examples.
#' @examples \donttest{
#' keys_delete(key=999999)
#' }

keys_delete <- function(key=NULL, config=NULL)
{
  assert_that(!is.null(key))
  do_DELETE(path=sprintf('account/keys/%s', key), config=config)
}
