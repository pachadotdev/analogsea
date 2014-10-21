#' Generate cloud config file.
#' 
#' This takes a template stored in \code{inst/cloudconfig} and inserts
#' ssh_keys into the first user.
#' 
#' @param name Name of template
#' @inheritParams droplet_create
#' @export
#' @keywords internal
cloud_config <- function(name, ssh_keys = NULL) {
  path <- system.file("cloudconfig", paste0(name, ".yaml"), 
    package = "analogsea")
  if (identical(path, "")) {
    stop("Could not find config template for ", name, call. = FALSE)
  }
  
  config <- yaml::yaml.load_file(path)
  
  # Insert keys
  ssh_keys <- lapply(standardise_keys(ssh_keys), as.key)
  public <- pluck(ssh_keys, "public_key", "character")
  
  config$users[[1]]$`ssh-authorized-keys` <- public
  
  config
}
