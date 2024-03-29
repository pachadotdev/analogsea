# dockerfile: script that descibes dependencies
# docker pull:  remote image -> local image
# docker build: dockerfile -> image, execute dockerfile and caches the result
#   as a binary
# docker run:   image -> container, every time you run you get a new container
#               by default
# docker ps -q -a | xargs docker rm

#' Docklets: docker on droplets.
#'
#' @export
#'
#' @inheritParams droplet_create
#' @param size (character) Size slug identifier. See \code{\link{sizes}()} for
#'   a complete list. Default: s-1vcpu-2gb
#' @param droplet A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param all (logical) List all containers or images. Default: \code{TRUE}
#' @param repo (character) Docker name, can be local to the Droplet or remote,
#' e.g., \code{rocker/rstudio}
#' @param rm (logical) Automatically remove the container when it exits.
#' Default: \code{FALSE}
#' @param container (character) Container name, can be partial (though has
#' to be unique)
#' @param ... For \code{docklet_create}, additional options passed down to
#' \code{\link[httr]{POST}}. For \code{docklet_run}, additional arguments
#' combined and applied to docker statement.
#' @param cmd (character) A docker command (e.g., \code{"run"})
#' @param args (character) Docker args
#' @param docker_args (character) Docker args
#' @param user (character) User name. required.
#' @param password (character) Password. required. can not be 'rstudio'
#' @param email (character) E-mail address. Default: \code{"rstudio@@example.com"}
#' @param img (character) Docker image (not a DigitalOcean image). Default:
#' \code{'rocker/rstudio'}
#' @param port (character) Port. Default: \code{8787}
#' @param volume (character) Volume. Can use to bind a volume.
#' @param dir (character) Working directory inside the container.
#' @param browse (logical) If \code{TRUE}, open RStudio instance in your default
#' browser.
#' @param ssh_user (character) User account for ssh commands against droplet.
#' Default: root
#' @param add_users (logical) Add users or not when installing RStudio server.
#' Default: FALSE
#' @param path (character) Path to a directory with Shiny app files
#' @param keyfile Optional private key file.
#' @param ssh_passwd Optional passphrase or callback function for authentication.
#' Refer to the \code{ssh::ssh_connect} documentation for more details.
#' @param verbose If TRUE, will print command before executing it.
#' @seealso \code{\link{docklets_create}}
#'
#' @return all functions return a droplet
#'
#' @section URLs:
#' If you need to figure out the URL for your RStudio or Shiny server
#' instance, you can construct like \code{http://<ip address>:<port>} where
#' IP address can most likely be found like \code{d$networks$v4[[1]]$ip_address}
#' and the port is the port you set in the function call.
#'
#' @section Managing Docker containers from R:
#' There's a few things to be note about managing Docker containers from
#' analogsea:
#'
#' - To see running containers run `docklet_ps(d)`
#' - To get get logs run `droplet_ssh(d, "docker logs <container ID>")`
#' - To get a continuous feed of the logs run
#' `droplet_ssh(d, "docker logs -f <container ID>")`
#' - Do not use `docker exec -ti` as you do not want an interactive session -
#' it will not work from within R. If you log into your DigitalOcean droplet
#' you can do `docker exec -ti`
#' - To install R package dependencies for a Shiny app, or similar, run
#' `droplet_ssh(d, "docker exec <ID> R -e 'install.packages(\"pkg-name\")'")`
#' where `d` is your droplet object and `<ID>` is the docker container ID
#'
#' @template dropid
#'
#' @examples
#' \dontrun{
#' d <- docklet_create()
#' d <- droplet(d$id)
#' d %>% docklet_pull("dockerpinata/sqlite")
#' d %>% docklet_images()
#'
#' # sqlite
#' d %>% docklet_run("dockerpinata/sqlite", "sqlite3 --version", rm = TRUE)
#' d %>% docklet_ps()
#'
#' # cowsay
#' d %>% docklet_pull("chuanwen/cowsay")
#' d %>% docklet_run("chuanwen/cowsay", rm = TRUE)
#'
#' # docker images
#' d %>% docklet_images()
#'
#' # install various R versions via Rocker
#' d %>% docklet_pull("rocker/r-base")
#' d %>% docklet_pull("rocker/r-devel")
#' d %>% docklet_pull("rocker/r-ver:3.2")
#' d %>% docklet_run("rocker/r-ver:3.2", "R --version", rm = TRUE)
#' d %>% docklet_run("rocker/r-ver:3.2", "Rscript -e '2 + 3'", rm = TRUE)
#'
#' # Run a docklet containing rstudio
#' d %>% docklet_rstudio(user = "foo", password = "bar")
#'
#' # Delete a droplet
#' d %>% droplet_delete()
#'
#' # Add users to an Rstudio instance
#' ## This adds 100 users to the instance, with username/passwords
#' ## following pattern user1/user1 ... through 100
#' d <- docklet_create()
#' d <- droplet(d$id)
#' d %>% docklet_rstudio(user = "foo", password = "bar") %>%
#'  docklet_rstudio_addusers(user = "foo", password = "bar")
#'
#' # Spin up a Shiny server (opens in default browser)
#' (d <- docklet_create())
#' d %>% docklet_shinyserver()
#' docklet_create() %>% docklet_shinyserver()
#'
#' # Spin up a Shiny server with an app (opens in default browser)
#' d <- docklet_create(); d <- droplet(d$id)
#' path <- system.file("examples", "widgets", package = "analogsea")
#' d %>% docklet_shinyapp(path)
#' ## uploading more apps - use droplet_upload, then navigate in browser
#' ### if you try to use docklet_shinyapp again on the same droplet, it will error
#' path2 <- system.file("examples", "mpg", package = "analogsea")
#' d %>% droplet_upload(path2, "/srv/shinyapps") # then go to browser
#' }
docklet_create <- function(name = random_name(),
                           size = getOption("do_size", "s-1vcpu-2gb"),
                           region = getOption("do_region", "sfo3"),
                           ssh_keys = getOption("do_ssh_keys", NULL),
                           backups = getOption("do_backups", NULL),
                           ipv6 = getOption("do_ipv6", NULL),
                           private_networking =
                             getOption("do_private_networking", NULL),
                           tags = list(),
                           wait = TRUE,
                           image = "docker-20-04",
                           keyfile = NULL,
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
    tags = tags,
    wait = wait,
    ...
  )
}

#' @export
#' @rdname docklet_create
docklet_ps <- function(droplet, all = TRUE, ssh_user = "root") {
  docklet_docker(droplet, "ps",  if (all) "-a", ssh_user = ssh_user)
}

#' @export
#' @rdname docklet_create
docklet_images <- function(droplet, all = TRUE, ssh_user = "root") {
  docklet_docker(droplet, "images", if (all) "-a", ssh_user = ssh_user)
}

#' @export
#' @rdname docklet_create
docklet_pull <- function(droplet, repo, ssh_user = "root", keyfile = NULL,
  ssh_passwd = NULL, verbose = FALSE) {

  docklet_docker(droplet, "pull", repo, ssh_user = ssh_user,
    keyfile = keyfile, ssh_passwd = ssh_passwd, verbose = verbose)
}

#' @export
#' @rdname docklet_create
docklet_run <- function(droplet, ..., rm = FALSE, name = NULL,
  ssh_user = "root", keyfile = NULL, ssh_passwd = NULL, verbose = FALSE) {

  docklet_docker(droplet,
    "run", c(
      if (rm) " --rm",
      if (!is.null(name)) paste0(" --name=", name),
      ...
    ),
    ssh_user = ssh_user, keyfile = keyfile, ssh_passwd = ssh_passwd,
    verbose = verbose
  )
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
docklet_docker <- function(droplet, cmd, args = NULL, docker_args = NULL,
  ssh_user = "root", keyfile = NULL, ssh_passwd = NULL, verbose = FALSE) {

  check_for_a_pkg("ssh")
  args <- paste(args, collapse = " ")
  droplet_ssh(
    droplet,
    user = ssh_user, keyfile = keyfile, ssh_passwd = ssh_passwd,
    paste(c("docker", docker_args, cmd, args), collapse = " "),
    verbose = verbose)
}

#' @export
#' @rdname docklet_create
docklet_rstudio <- function(droplet, user, password,
  email = 'rstudio@example.com', img = 'rocker/rstudio', port = '8787',
  volume = '', dir = '', browse = TRUE, add_users = FALSE,
  ssh_user = "root", keyfile = NULL, ssh_passwd = NULL, verbose = FALSE) {

  if (missing(user)) stop("'user' is required")
  if (missing(password)) stop("'password' is required")
  if (password == "rstudio") stop("supply a 'password' other than 'rstudio'")
  droplet <- as.droplet(droplet)

  docklet_pull(droplet, img, ssh_user, keyfile = keyfile,
    ssh_passwd = ssh_passwd, verbose = verbose)
  docklet_run(droplet,
    " -d",
    " -p ", paste0(port, ":8787"),
    cn(" -v ", volume),
    cn(" -w", dir),
    paste0(" -e USER=", user),
    paste0(" -e PASSWORD=", password),
    paste0(" -e EMAIL=", email), " ",
    img,
    ifelse(add_users, ' bash -c "add-students && supervisord" ', ' '),
    ssh_user = ssh_user,
    keyfile = keyfile,
    ssh_passwd = ssh_passwd
  )

  url <- sprintf("http://%s:%s/", droplet_ip(droplet), port)
  if (browse) {
    Sys.sleep(4) # give Rstudio server a few seconds to start up
    browseURL(url)
  }

  invisible(droplet)
}

#' @export
#' @rdname docklet_create
docklet_rstudio_addusers <- function(droplet, user, password,
  img = 'rocker/rstudio', port = '8787', ssh_user = "root", keyfile = NULL,
  ssh_passwd = NULL, verbose = FALSE) {

  check_for_a_pkg("ssh")
  if (missing(user)) stop("'user' is required")
  if (missing(password)) stop("'password' is required")
  if (password == "rstudio") stop("supply a 'password' other than 'rstudio'")
  droplet <- as.droplet(droplet)

  # check if rstudio container already running, shut down if up
  cons <- docklet_ps_data(droplet, ssh_user = ssh_user,
    keyfile = keyfile, ssh_passwd = ssh_passwd, verbose = verbose)
  id <- cons[ grep("rocker/rstudio:latest", cons$image), "container.id" ]
  if (length(id) > 0) {
    docklet_stop(droplet, container = id)
    docklet_rm(droplet, container = id)
  }

  # spin up new container with users
  docklet_run(
    droplet,
    " -d",
    " -p ", paste0(port, ":8787"),
    paste0(" -e USER=", user),
    paste0(" -e PASSWORD=", password),
    " ", img,
    ' bash -c "add-students && supervisord"',
    verbose = verbose
  )
}

#' @export
#' @rdname docklet_create
docklet_shinyserver <- function(droplet,
                            img = 'rocker/shiny',
                            port = '3838',
                            volume = '',
                            dir = '',
                            browse = TRUE,
                            ssh_user = "root",
                            keyfile = NULL) {
  droplet <- as.droplet(droplet)

  docklet_pull(droplet, img, ssh_user, keyfile = keyfile)
  docklet_run(droplet,
              " -d",
              " -p ", paste0(port, ":3838"),
              cn(" -v ", volume),
              cn(" -w", dir),
              " ",
              img,
              ssh_user = ssh_user,
              keyfile = keyfile
  )

  url <- sprintf("http://%s:%s/", droplet_ip(droplet), port)
  if (browse) {
    Sys.sleep(4) # give Rstudio Shiny Server a few seconds to start up
    browseURL(url)
  }

  invisible(droplet)
}

#' @export
#' @rdname docklet_create
docklet_shinyapp <- function(droplet,
                             path,
                             img = 'rocker/shiny',
                             port = '80',
                             dir = '',
                             browse = TRUE,
                             ssh_user = "root",
                             keyfile = NULL) {
  check_for_a_pkg("ssh")
  droplet <- as.droplet(droplet)
  # move files to server
  droplet_ssh(droplet, "mkdir -p /srv/shinyapps", keyfile = keyfile)
  droplet_upload(droplet, path, "/srv/shinyapps/", keyfile = keyfile)
  # spin up shiny server
  docklet_shinyserver(droplet, img, port, 
                      volume = '/srv/shinyapps/:/srv/shiny-server/',
                      dir, browse, ssh_user, keyfile)
}
