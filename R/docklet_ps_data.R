# get ps info as a data.frame ----------------------
## FIXME - don't want to basically duplicate other internal fxns,
## but, the base fxn do_system() needs the change to intern=TRUE
docklet_ps_data <- function(droplet, all = TRUE, ssh_user = "root") {
  tmp <- docklet_docker2(droplet, "ps",  if (all) "-a", ssh_user = ssh_user)
  tmp <- paste0(gsub("\\s\\s+", ",", unname(sapply(tmp, strTrim))), collapse = "\n")
  tmp <- gsub("\"|'", "", tmp)
  df <- read.csv(text = paste0(tmp, "\n", collapse = ""), stringsAsFactors = FALSE)
  setNames(df, tolower(names(df)))
}

docklet_docker2 <- function(droplet, cmd, args = NULL, docker_args = NULL, ssh_user = "root") {
  args <- paste(args, collapse = "")
  droplet_ssh2(droplet, user = ssh_user, paste(c("docker", docker_args, cmd, args), collapse = " "))
}

droplet_ssh2 <- function(droplet, ..., user = "root", verbose = FALSE) {
  droplet <- as.droplet(droplet)

  lines <- paste(c(...), collapse = " \\\n&& ")
  if (lines == "") stop("Provide commands", call. = FALSE)
  cmd <- paste0(
    "ssh ", ssh_options(),
    " ", user, "@", droplet_ip(droplet),
    " ", shQuote(lines)
  )
  do_system2(droplet, cmd, verbose = verbose)
}

do_system2 <- function(droplet, cmd, verbose = FALSE) {
  cli_tools()
  mssg(verbose, cmd)
  system(cmd, intern = TRUE)
}
