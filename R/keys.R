key_url <- function(key = NULL) {
  url("account", "keys", key)
}
#' @export
as.url.key <- function(x, ...) {
  key_url(x$id)
}

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
  res <- do_GET(key_url(), query = list(page = page, per_page = per_page), ...)
  as.key(res)
}

#' @rdname keys
#' @export
key <- function(x, ...) {
  as.key(do_GET(key_url(x), ...))
}

#' @rdname keys
#' @export
as.key <- function(x) UseMethod("as.key")
#' @export
as.key.list <- function(x) list_to_object(x, "ssh_key", class = "key")
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

#' Create, update, and delete ssh keys.
#'
#' @param name (character) The name to give the new SSH key in your account.
#' @param public_key (character) A string containing the entire public key.
#' @param key (key) Key to modify.
#' @param ... Other options passed on to low-level API methods.
#' @name key-crud
#' @examples \dontrun{
#' k <- key_create("key", readLines("~/.ssh/id_rsa.pub"))
#' k <- key_rename(k, "new_name")
#' key_delete(k)
#' }
NULL

#' @rdname key-crud
#' @export
key_create <- function(name, public_key, ...) {
  res <- do_POST(key_url(), query = list(
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

#' Standardise specification of ssh keys.
#'
#' @param ssh_keys An integer vector of given key ids, a character vector
#'   of key ids, or NULL, to use all ssh keys in account.
#' @return A integer vector of key ids.
#' @export
#' @examples
#' \dontrun{
#' standardise_keys(123)
#' standardise_keys(123L)
#' standardise_keys()
#' standardise_keys("hadley")
#' }
standardise_keys <- function(ssh_keys = NULL) {
  if (is.integer(ssh_keys)) return(ssh_keys)
  if (is.numeric(ssh_keys)) return(as.integer(ssh_keys))

  if (is.null(ssh_keys)) {
    ssh_keys <- keys()

    names <- pluck(ssh_keys, "name", character(1))
    message("Using default ssh keys: ", paste0(names, collapse = ", "))
  } else if (is.character(ssh_keys)) {
    ssh_keys <- lapply(ssh_keys, as.key)
  } else {
    stop("Unknown specification for ssh_keys", call. = FALSE)
  }

  unname(pluck(ssh_keys, "id", integer(1)))
}
