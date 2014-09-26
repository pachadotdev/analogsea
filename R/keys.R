#' List your ssh keys, or get a single key
#'
#' @export
#' @param x For \code{key} the numeric id. For \code{as.key}, a number (the id),
#'   a string (the name), or a key.
#' @inheritParams droplets
#' @examples \dontrun{
#' keys()
#' as.key(328037)
#' as.key("hadley")
#' }
keys <- function(...) {
  res <- do_keys(key, ...)
  names(res$ssh_keys) <- pluck(res$ssh_keys, "name", character(1))
  lapply(res$ssh_keys, as.key)
}

#' @rdname keys
#' @export
key <- function(x) {
  res <- do_key(x)
  as.key(res$ssh_key)
}

#' @rdname keys
#' @export
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

#' @export
#' @rdname keys
do_keys <- function(key = NULL, page=1, per_page=25, config=NULL) {
  do_GET("parsed", "account/keys", 
    query = list(page = page, per_page = per_page), 
    config = config
  )
}

#' @export
#' @rdname keys
do_key <- function(x, config = NULL) {
  do_GET("parsed", sprintf('account/keys/%s', x), config = config)
}

#' Create, update, and delete ssh keys.
#'
#' @param name (character) The name to give the new SSH key in your account.
#' @param public_key (character) A string containing the entire public key.
#' @param key (key) Key to modify.
#' @param ... Other options passed on to low-level API methods.
#' @name key-crud
#' @examples \donttest{
#' k <- key_create("key", readLines("~/.ssh/id_rsa.pub"))
#' k <- key_rename(k, "new_name")
#' key_delete(k)
#' }
NULL

#' @rdname key-crud
#' @export
key_create <- function(name, public_key, ...) {
  res <- do_POST("parsed", path = 'account/keys', 
    args = list(name = name, public_key = public_key), ...)
  as.key(res$ssh_key)
}

#' @rdname key-crud
#' @export
key_rename <- function(key, name, ...) {
  key <- as.key(key)
  
  res <- do_PUT("parsed", path = sprintf('account/keys/%s', key$id), 
    args = list(name = name), ...)
  as.key(res$ssh_key)
}

#' @rdname key-crud
#' @export
key_delete <- function(key, ...) {
  key <- as.key(key)

  res <- do_DELETE(path = sprintf('account/keys/%s', key$id), ...)
  invisible(TRUE)
}
