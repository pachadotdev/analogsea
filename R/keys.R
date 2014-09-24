#' List your ssh keys, or get a single key
#'
#' @export
#' @param key (numeric/character) An ssh key id (e.g., 3), or key fingerprint 
#' (e.g., c8:6f:72:7e:2f:5b:21:38:2d:9a:0b:ef:0f:75:c8:2d). If none given, 
#' all your keys are listed. (optional)
#' @template params
#' @examples \dontrun{
#' keys()
#' as.key(89103)
#' as.key("mykey")
#' }
keys <- function(...) {
  res <- do_keys(key, ...)
  names(res$ssh_keys) <- pluck(res$ssh_keys, "name", character(1))
  lapply(res$ssh_keys, as.key)
}

do_keys <- function(key = NULL, page=1, per_page=25, config=NULL) {
  do_GET("parsed", "account/keys", 
    query = list(page = page, per_page = per_page), 
    config = config
  )
}

key <- function(id) {
  res <- do_key(id)
  as.key(res$id)
}

do_key <- function(id, config = NULL) {
  do_GET("parsed", sprintf('account/keys/%s', key), config = config)
}

as.key <- function(x) UseMethod("as.key")
#' @export
as.key.list <- function(x) structure(x, class = "key")
#' @export 
as.key.numeric <- function(x) key(x)
#' @export
as.key.character <- function(x) keys()[[x]]
#' @export
as.key.key <- function(x) x

#' @export
print.key <- function(x, ...) {
  cat("<key> ", x$name, " (", x$id, ")", "\n", sep = "")
  cat("  Fingerprint: ", x$fingerprint, "\n", sep = "")
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
