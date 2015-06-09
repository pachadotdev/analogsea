# dockerfile: script that descibes dependencies
# docker pull:  remote image -> local image
# docker build: dockerfile -> image, execute dockerfile and caches the result as a binary
# docker run:   image -> container, every time you run you get a new container
#               by default
# docker ps -q -a | xargs docker rm

#' Docklets: docker on droplets.
#'
#' @export
#'
#' @inheritParams droplet_create
#' @param droplet A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param all (logical) List all containers. Default: \code{TRUE}
#' @param repo (character) Docker name, can be local to the Droplet or remote,
#' e.g., \code{rocker/rstudio}
#' @param rm (logical) Automatically remove the container when it exits.
#' Default: \code{FALSE}
#' @param container (character) Container name, can be partial (though has
#' to be unique)
#' @param ... For \code{docklet_create}, additional options passed down to
#' \code{\link[httr]{POST}}. For \code{docklet_run}, additional arguments combined
#' and applied to docker statement.
#' @param cmd (character) A docker command (e.g., \code{"run"})
#' @param args (character) Docker args
#' @param docker_args (character) Docker args
#' @param user (character) User name. Default: \code{"rstudio"}
#' @param password (character) Password. Default: \code{"rstudio"}
#' @param email (character) Password. Default: \code{"rstudio@@example.com"}
#' @param img (character) Docker image (not a DigitalOcean image). Default:
#' \code{'rocker/rstudio'}
#' @param port (character) Port. Default: \code{8787}
#' @param volume (character) Volume. Can use to bind a volume.
#' @param dir (character) Working directory inside the container.
#' @param browse (logical) If \code{TRUE}, open RStudio instance in your default
#' browser.
#' @param ssh_user (character) User account for ssh commands against droplet. Default: root
#' @param add_users (logical) Add users or not when installing RStudio server. Default: FALSE
#' @examples
#' \dontrun{
#' d <- docklet_create()
#' d %>%
#'   docklet_pull("eddelbuettel/ubuntu-r-base") %>%
#'   docklet_images()
#' d %>% docklet_images()
#'
#' d %>% docklet_run("eddelbuettel/ubuntu-r-base", "R --version", rm = TRUE)
#' d %>% docklet_ps()
#'
#' # Run a docklet containing rstudio
#' d %>% docklet_rstudio()
#'
#' # Delete a droplet
#' d %>% droplet_delete()
#'
#' # Add users to an Rstudio instance
#' ## This adds 100 users to the instance, with username/passwords
#' ## following pattern user1/user1 ... through 100
#' d <- docklet_create()
#' d %>% docklet_rstudio() %>% docklet_rstudio_addusers()
#' }
docklet_create <- function(name = random_name(),
                           size = getOption("do_size", "1gb"),
                           region = getOption("do_region", "sfo1"),
                           ssh_keys = getOption("do_ssh_keys", NULL),
                           backups = getOption("do_backups", NULL),
                           ipv6 = getOption("do_ipv6", NULL),
                           private_networking = getOption("do_private_networking", NULL),
                           wait = TRUE,
                           image = "docker",
                           ...) {
  droplet_create(
    name = name,
    size = size,
    image = image,
    region = region,
    ssh_keys = ssh_keys,
    backups = backups,
    ipv6 = ipv6,
    private_networking = private_networking,
    wait = wait
  )
}

#' @export
#' @rdname docklet_create
docklet_ps <- function(droplet, all = TRUE, ssh_user = "root") {
  docklet_docker(droplet, "ps",  if (all) "-a", ssh_user = ssh_user)
}

#' @export
#' @rdname docklet_create
docklet_images <- function(droplet, ssh_user = "root") {
  docklet_docker(droplet, "images", ssh_user = ssh_user)
}

#' @export
#' @rdname docklet_create
docklet_pull <- function(droplet, repo, ssh_user = "root") {
  docklet_docker(droplet, "pull", repo, ssh_user = ssh_user)
}

#' @export
#' @rdname docklet_create
docklet_run <- function(droplet, ..., rm = FALSE, name = NULL, ssh_user = "root") {
  docklet_docker(droplet,
    "run", c(
    if (rm) " --rm",
    if (!is.null(name)) paste0(" --name=", name),
    ...
  ), ssh_user = ssh_user)
}

#' @export
#' @rdname docklet_create
docklet_stop <- function(droplet, container, ssh_user = "root") {
  docklet_docker(droplet, "stop", container, ssh_user = ssh_user)
}


#' @export
#' @rdname docklet_create
docklet_rm <- function(droplet, container, ssh_user = "root") {
  docklet_docker(droplet, "rm", container, ssh_user = ssh_user)
}

#' @export
#' @rdname docklet_create
docklet_docker <- function(droplet, cmd, args = NULL, docker_args = NULL, ssh_user = "root") {
  args <- paste(args, collapse = "")
  droplet_ssh(droplet, user = ssh_user, paste(c("docker", docker_args, cmd, args), collapse = " "))
}

#' @export
#' @rdname docklet_create
docklet_rstudio <- function(droplet,
                            user = 'rstudio', password = 'rstudio',
                            email = 'rstudio@example.com',
                            img = 'rocker/rstudio',
                            port = '8787',
                            volume = '',
                            dir = '',
                            browse = TRUE,
                            add_users = FALSE,
                            ssh_user = "root") {
  droplet <- as.droplet(droplet)

  docklet_pull(droplet, img, ssh_user)
  docklet_run(droplet,
    " -d",
    " -p ", port, ":8787",
    cn(" -v ", volume),
    cn(" -w", dir),
    " -e USER=", user,
    " -e PASSWORD=", password,
    " -e EMAIL=", email, " ",
    img,
    ifelse(add_users, ' bash -c "add-students && supervisord" ', ' '),
    ssh_user = ssh_user
  )

  url <- sprintf("http://%s:%s/", droplet_ip(droplet), port)
  if (browse) {
    Sys.sleep(4) # give Rstudio server a few seconds to start up
    browseURL(url)
  }

  invisible(url)
}

#' @export
#' @rdname docklet_create
docklet_rstudio_addusers <- function(droplet,
                                     user = 'rstudio', password = 'rstudio',
                                     img = 'rocker/rstudio',
                                     port = '8787') {
  droplet <- as.droplet(droplet)

  # check if rstudio container already running, shut down if up
  cons <- docklet_ps_data(droplet)
  id <- cons[ grep("rocker/rstudio:latest", cons$image), "container.id" ]
  if (length(id) > 0) {
    docklet_stop(droplet, container = id)
    docklet_rm(droplet, container = id)
  }

  # spin up new container with users
  docklet_run(droplet,
              " -d",
              " -p ", port, ":8787",
              " -e USER=", user,
              " -e PASSWORD=", password,
              " ", img,
              ' bash -c "add-students && supervisord"'
  )
}

cn <- function(x, y) if (nchar(y) == 0) y else paste0(x, y)

strExtract <- function(str, pattern) regmatches(str, regexpr(pattern, str))

strTrim <- function(str) gsub("^\\s+|\\s+$", "", str)
