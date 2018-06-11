# get ps info as a data.frame ----------------------
## FIXME - don't want to basically duplicate other internal fxns,
## but, the base fxn do_system() needs the change to intern=TRUE
docklet_ps_data <- function(droplet, all = TRUE, ssh_user = "root", 
  keyfile = NULL, ssh_passwd = NULL, verbose = FALSE) {

  tmp <- docklet_docker2(droplet, "ps",  if (all) "-a", ssh_user = ssh_user, 
    keyfile = keyfile, ssh_passwd = ssh_passwd)
  tmp <- paste0(gsub("\\s\\s+", ",", unname(sapply(tmp, strTrim))), 
    collapse = "\n")
  tmp <- gsub("\"|'", "", tmp)
  df <- read.csv(text = paste0(tmp, "\n", collapse = ""), 
    stringsAsFactors = FALSE)
  stats::setNames(df, tolower(names(df)))
}

docklet_docker2 <- function(droplet, cmd, args = NULL, docker_args = NULL, 
  ssh_user = "root", keyfile = NULL, ssh_passwd = NULL, verbose = FALSE) {

  args <- paste(args, collapse = "")
  droplet_ssh(droplet, paste(c("docker", docker_args, cmd, args), 
    collapse = " "), 
    user = ssh_user, keyfile = keyfile, ssh_passwd = ssh_passwd, 
    verbose = verbose
  )
}
