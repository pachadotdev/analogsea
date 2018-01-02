#' Create many new droplets.
#'
#' There are defaults for each of size, image, and region so that a quick
#' one-liner with one parameter is possible: simply specify the name of the
#' droplet and your'e up and running.
#'
#' @export
#' @param names (character) Names of the droplets. The human-readable string
#' you wish to use when displaying the Droplet name. The name, if set to
#' a domain name managed in the DigitalOcean DNS management system, will
#' configure a PTR record for the Droplet. The name set during creation will
#' also determine the hostname for the Droplet in its internal configuration.
#' Default: picks a random name from \code{\link{words}} if none supplied.
#' @inheritParams droplet_create
#'
#' @details Note that if you exit the R session or kill the function call
#' after it's in waiting process (the string of ...), the droplet creation
#' will continue.
#'
#' @return Two or more droplet objects
#'
#' @examples \dontrun{
#' # if no names given, creates two droplets with random names
#' droplets_create()
#'
#' # give names
#' droplets_create(names = c('drop1', 'drop2'))
#' droplets_create(names = c('drop3', 'drop4'))
#'
#' # add tags
#' (d <- droplets_create(tags = 'mystuff'))
#' invisible(lapply(d, summary))
#' }
droplets_create <- function(names = NULL,
                           size = getOption("do_size", "512mb"),
                           image = getOption("do_image", "ubuntu-14-04-x64"),
                           region = getOption("do_region", "sfo1"),
                           ssh_keys = getOption("do_ssh_keys", NULL),
                           backups = getOption("do_backups", NULL),
                           ipv6 = getOption("do_ipv6", NULL),
                           private_networking =
                             getOption("do_private_networking", NULL),
                           tags = NULL,
                           user_data = NULL,
                           cloud_config = NULL,
                           wait = TRUE,
                           ...) {

  ssh_keys <- standardise_keys(ssh_keys)
  if (length(ssh_keys) == 0) {
    warning("You have not specified any ssh_keys. This is NOT recommended.",
      " You will receive an email with the root password in a few minutes",
            call. = FALSE)
  }

  # Generate user_data if cloud_config specified
  if (!is.null(cloud_config)) {
    if (!is.null(user_data)) {
      stop("You may only specify one of cloud_config and user_data.",
           call. = FALSE)
    }

    user_data <- cloud_config(cloud_config, ssh_keys)
  }

  if (is.null(names)) names <- replicate(2, random_name())

  res <- do_POST('droplets',
                 body = list(
                   names = names,
                   size = unbox(size),
                   image = unbox(image),
                   region = unbox(region),
                   ssh_keys = I(ssh_keys),
                   backups = unbox(backups),
                   ipv6 = unbox(ipv6),
                   private_networking = unbox(private_networking),
                   tags = I(tags),
                   user_data = unbox(user_data)
                 ), ...)
  droplets <- lapply(res$droplets, function(z) droplet(z$id))

  for (i in seq_along(droplets)) {
    message("NB: This costs $", droplets[[i]]$size$price_hourly, " / hour ",
            "until you droplet_delete() it")
  }

  if (wait) {
    for (i in seq_along(droplets)) {
      droplet_wait(droplets[[i]])
    }
    droplets
  } else {
    droplets
  }
}
