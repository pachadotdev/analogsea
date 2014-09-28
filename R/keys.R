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
keys <- function(..., page = 1, per_page = 25) {
  res <- do_GET("account/keys", query = list(page = page, per_page = per_page), ...)
  as.key(res)
}

#' @rdname keys
#' @export
key <- function(x) {
  res <- do_key(x)
  as.key(res)
}

#' @rdname keys
#' @export
as.key <- function(x) UseMethod("as.key")
#' @export
as.key.list <- function(x) {
  if (!is.null(x$ssh_keys)) {
    keys <- lapply(x$ssh_keys, structure, class = "key")
    names(keys) <- pluck(x$ssh_keys, "name", character(1))
    keys
  } else if (!is.null(x$ssh_key)) {
    structure(x$ssh_key, class = "key")  
  } else {
    stop("Don't know how to coerce this list to a key", call. = FALSE) 
  }
}
#' @export 
as.key.numeric <- function(x) key(x)
#' @export
as.key.character <- function(x) keys()[[x]]
#' @export
as.key.key <- function(x) x

#' @export
as.url.key <- function(x, ...) {
  sprintf('%s/account/keys/%s', do_base, x$id)
}

#' @export
print.key <- function(x, ...) {
  cat("<key> ", x$name, " (", x$id, ")", "\n", sep = "")
  cat("  Fingerprint: ", x$fingerprint, "\n", sep = "")
}

#' @export
#' @rdname keys
do_key <- function(x, ...) {
  do_GET(sprintf('account/keys/%s', x), ...)
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
  res <- do_POST('account/keys', query = list(
    name = name, 
    public_key = public_key
  ), ...)
  as.key(res)
}

#' @rdname key-crud
#' @export
key_rename <- function(key, name, ...) {
  key <- as.key(key)
  as.key(do_PUT(key, query = list(name = name), ...))
}

#' @rdname key-crud
#' @export
key_delete <- function(key, ...) {
  key <- as.key(key)
  do_DELETE(key, ...)
}
