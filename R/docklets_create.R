#' Docklets: docker on droplets - create many docklets
#'
#' @export
#' @inheritParams droplet_create
#' @inheritParams droplets_create
#' @return Two or more droplet objects
#' @examples
#' \dontrun{
#' # if no names given, creates two droplets with random names
#' docklets_create()
#'
#' # give names
#' docklets_create(names = c('drop1', 'drop2'))
#' docklets_create(names = c('drop3', 'drop4'))
#' }
docklets_create <- function(names = NULL,
                           size = getOption("do_size", "1gb"),
                           region = getOption("do_region", "sfo1"),
                           ssh_keys = getOption("do_ssh_keys", NULL),
                           backups = getOption("do_backups", NULL),
                           ipv6 = getOption("do_ipv6", NULL),
                           private_networking =
                             getOption("do_private_networking", NULL),
                           wait = TRUE,
                           image = "docker",
                           ...) {
  droplets_create(
    names = names,
    size = size,
    image = image,
    region = region,
    ssh_keys = ssh_keys,
    backups = backups,
    ipv6 = ipv6,
    private_networking = private_networking,
    wait = wait,
    ...
  )
}
