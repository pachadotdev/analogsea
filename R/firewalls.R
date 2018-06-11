firewall_url <- function(firewall = NULL) {
  url("firewalls", firewall)
}

#' @param x Object to coerce to an firewall.
#' @export
#' @rdname firewalls
as.firewall <- function(x) UseMethod("as.firewall")
#' @export
as.firewall.list <- function(x) list_to_object(x, "firewall")
#' @export
as.firewall.firewall <- function(x) x
#' @export
as.firewall.character <- function(x) firewall(x)

#' Get list of firewalls and their metadata, or a single firewall
#'
#' @export
#' @param id (numeric) firewall id.
#' @param name (character) a firewall name
#' @param inbound_rules (list) inbound rules
#' @param outbound_rules (list) outbound rules
#' @param droplet_ids (numeric/integer) droplet ids
#' @param tags (character) tag strings
#' @inheritParams droplets
#' @examples \dontrun{
#' # list firewalls
#' firewalls()
#' 
#' # create a firewall
#' inbound <- list(list(protocol = "tcp", ports = "80", 
#'   sources = list(addresses = "18.0.0.0/8")))
#' outbound <- list(list(protocol = "tcp", ports = "80", 
#'   destinations = list(addresses = "0.0.0.0/0")))
#' res <- firewall_create("myfirewall", inbound, outbound)
#' res
#' 
#' # get a firewall
#' firewall("d19b900b-b03e-4e5d-aa85-2ff8d2786f28")
#' as.firewall("d19b900b-b03e-4e5d-aa85-2ff8d2786f28")
#' }
firewalls <- function(page = 1, per_page = 25, ...) {
  res <- do_GET(firewall_url(),
                query = list(page = page, per_page = per_page), ...)
  as.firewall(res)
}

#' @export
#' @rdname firewalls
firewall <- function(id, ...) {
  res <- do_GET(firewall_url(id), ...)
  as.firewall(res)
}

#' @export
#' @rdname firewalls
firewall_create <- function(name, inbound_rules, outbound_rules, droplet_ids = NULL,
                          tags = NULL, ...) {
  body <- ascompact(
    list(name = name, inbound_rules = inbound_rules,
      outbound_rules = outbound_rules, droplet_ids = droplet_ids,
      tags = tags))
  as.firewall(do_POST("firewalls", ..., body = body))
}

#' @export
#' @rdname firewalls
firewall_update <- function(name, inbound_rules, outbound_rules, droplet_ids = NULL,
                          tags = NULL, ...) {
  body <- ascompact(
    list(name = name, inbound_rules = inbound_rules,
      outbound_rules = outbound_rules, droplet_ids = droplet_ids,
      tags = tags))
  as.firewall(do_PUT("firewalls", ..., body = body))
}

#' @export
print.firewall <- function(x, ...) {
  cat("<firewall> ", x$name, " (", x$id, ")", "\n", sep = "")
  cat("  Status:    ", x$status, "\n", sep = "")
}

#' @export
as.url.firewall <- function(x, ...) {
  firewall_url(x$id)
}

#' Delete a firewall
#'
#' @export
#' @param id A firewall id (not the name) to delete
#' @param ... Options passed on to httr::DELETE
#' @examples \dontrun{
#' firewall_delete(id="d19b900b-b03e-4e5d-aa85-2ff8d2786f28")
#' }
firewall_delete <- function(id, ...) {
  id <- as.firewall(id)
  do_DELETE(file.path('firewalls', id$id), ...)
}

#' Add/remove droplets to a firewall
#'
#' @export
#' @param id (character) A firewall id (not the name) to delete
#' @param droplet_ids (integer/numeric) a vector of droplet ids
#' @param ... Options passed on to httr::POST or httr::DELETE
#' @examples \dontrun{
#' drops <- droplets_create()
#' drop_ids <- vapply(drops, "[[", numeric(1), "id")
#' inbound <- list(list(protocol = "tcp", ports = "80", 
#'   sources = list(addresses = "18.0.0.0/8")))
#' outbound <- list(list(protocol = "tcp", ports = "80", 
#'   destinations = list(addresses = "0.0.0.0/0")))
#' res <- firewall_create("myfirewall", inbound, outbound)
#' firewall_add_droplets(id = res$id, droplet_ids = drop_ids)
#' firewalls()[[1]]$droplet_ids
#' firewall_remove_droplets(id = res$id, droplet_ids = drop_ids)
#' }
firewall_add_droplets <- function(id, droplet_ids, ...) {
  id <- as.firewall(id)
  body <- list(droplet_ids = droplet_ids)
  do_POST(file.path('firewalls', id$id, "droplets"), ..., 
    body = body)
}

#' @rdname firewall_add_droplets
#' @export
firewall_remove_droplets <- function(id, droplet_ids, ...) {
  id <- as.firewall(id)
  body <- list(droplet_ids = droplet_ids)
  do_DELETE(file.path('firewalls', id$id, "droplets"), ..., 
    encode = "json", body = body)
}

#' Add/remove tags to a firewall
#'
#' @export
#' @param id (character) A firewall id (not the name) to delete
#' @param tags (character) tag strings
#' @param ... Options passed on to httr::POST or httr::DELETE
#' @examples \dontrun{
#' drops <- droplets_create()
#' drop_ids <- vapply(drops, "[[", numeric(1), "id")
#' inbound <- list(list(protocol = "tcp", ports = "80", 
#'   sources = list(addresses = "18.0.0.0/8")))
#' outbound <- list(list(protocol = "tcp", ports = "80", 
#'   destinations = list(addresses = "0.0.0.0/0")))
#' res <- firewall_create("myfirewall", inbound, outbound)
#' 
#' tag_create(name = "foobar")
#' tags()
#' firewall_add_tags(id = res$id, tags = "foobar")
#' firewalls()[[1]]$tags
#' firewall_remove_tags(id = res$id, tags = "foobar")
#' }
firewall_add_tags <- function(id, tags, ...) {
  id <- as.firewall(id)
  body <- list(tags = tags)
  do_POST(file.path('firewalls', id$id, "tags"), ..., body = body)
}

#' @rdname firewall_add_tags
#' @export
firewall_remove_tags <- function(id, tags, ...) {
  id <- as.firewall(id)
  body <- list(tags = tags)
  do_DELETE(file.path('firewalls', id$id, "tags"), ..., 
    encode = "json", body = body)
}
