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
#' @keywords internal
#' @inheritParams droplet_new
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
#' d %>% droplet_delete()
#' }
docklet_create <- function(name = random_name(), 
                           size = getOption("do_size", "1gb"),
                           region = getOption("do_region", "sfo1"),
                           ssh_keys = getOption("do_ssh_keys", NULL),
                           backups = getOption("do_backups", NULL),
                           ipv6 = getOption("do_ipv6", NULL),
                           private_networking = getOption("do_private_networking", NULL),
                           wait = TRUE,
                           ...) {  
  droplet_new(
    name = name, 
    size = size, 
    image = "docker",
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
docklet_ps <- function(droplet, all = TRUE) {
  docklet_docker(droplet, "ps", if (all) "-a")
}

#' @export
#' @rdname docklet_create
docklet_images <- function(droplet) {
  docklet_docker(droplet, "images")
}

#' @export
#' @rdname docklet_create
docklet_pull <- function(droplet, repo) {
  docklet_docker(droplet, "pull", repo)
}

#' @export
#' @rdname docklet_create
docklet_run <- function(droplet, ..., rm = FALSE, name = NULL) {
  docklet_docker(droplet, "run", c(
    if (rm) " --rm", 
    if (!is.null(name)) paste0(" --name=", name),
    ...
  ))
}

#' @export
#' @rdname docklet_create
docklet_stop <- function(droplet, container) {
  docklet_docker(droplet, "stop", container)
}


#' @export
#' @rdname docklet_create
docklet_rm <- function(droplet, container) {
  docklet_docker(droplet, "rm", container)
}

#' @export
#' @rdname docklet_create
docklet_docker <- function(droplet, cmd, args = NULL, docker_args = NULL) {
  args <- paste(args, collapse = "")
  droplet_ssh(droplet, paste(c("docker", docker_args, cmd, args), collapse = " "))
}

#' @export
#' @rdname docklet_create
docklet_rstudio <- function(droplet, user = 'rstudio', password = 'rstudio', 
                            email = 'rstudio@example.com', 
                            img = 'eddelbuettel/ubuntu-rstudio', 
                            port = '8787', browse = TRUE, verbose = TRUE) {
  droplet <- as.droplet(droplet)
  
  docklet_pull(droplet, img)
  docklet_run(droplet,
    " -d", 
    " -p ", port, ":8787", 
    " -e USER=", user,
    " -e PASSWORD=", password,
    " -e EMAIL=", email, " ",
    img) 
  
  url <- sprintf("http://%s:%s/", droplet_ip(droplet), port)
  if (browse) {
    Sys.sleep(4) # give Rstudio server a few seconds to start up
    browseURL(url)
  }
  
  invisible(url)
}
