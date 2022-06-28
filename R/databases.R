database_url <- function(database = NULL) {
  url("databases", database)
}

#' Get all the available databases that can be used to create a droplet.
#'
#' @export
#' @inheritParams droplets
#' @return A data.frame with available databases (RAM, disk, no. CPU's) and
#' their costs
#' @param ... Named options passed on to \code{\link[httr]{GET}}.
#' @examples \dontrun{
#' databases()
#' }
databases <- function(page = 1, per_page = 25, ...) {
  res <- do_GET('databases', query = list(page = page, per_page = per_page), ...)
  databases <- res$databases
  
  d <- data.frame(
    id = pluck(databases, "id", character(1)),
    name = pluck(databases, "name", character(1)),
    engine = pluck(databases, "engine", character(1)),
    version = pluck(databases, "version", character(1)),
    protocol = pluck(databases, "version", character(1)),
    
    connection_uri = pluck(pluck(databases, "connection"), "uri", character(1)),
    connection_database = pluck(pluck(databases, "connection"), "database", character(1)),
    connection_host = pluck(pluck(databases, "connection"), "host", character(1)),
    connection_port = pluck(pluck(databases, "connection"), "port", integer(1)),
    connection_user = pluck(pluck(databases, "connection"), "user", character(1)),
    connection_password = pluck(pluck(databases, "connection"), "password", character(1)),
    connection_ssl = pluck(pluck(databases, "connection"), "ssl", logical(1)),
    
    private_connection_uri = pluck(pluck(databases, "private_connection"), "uri", character(1)),
    private_connection_database = pluck(pluck(databases, "private_connection"), "database", character(1)),
    private_connection_host = pluck(pluck(databases, "private_connection"), "host", character(1)),
    private_connection_port = pluck(pluck(databases, "private_connection"), "port", integer(1)),
    private_connection_user = pluck(pluck(databases, "private_connection"), "user", character(1)),
    private_connection_password = pluck(pluck(databases, "private_connection"), "password", character(1)),
    private_connection_ssl = pluck(pluck(databases, "private_connection"), "ssl", logical(1)),
    
    users_name = paste(sort(unlist(lapply(databases, function(x) {
      lapply(x$users, function(y) y$name) 
    })) %||% ""), collapse = ", "),
    users_password = paste(sort(unlist(lapply(databases, function(x) {
      lapply(x$users, function(y) y$role) 
    })) %||% ""), collapse = ", "),
    users_password = paste(sort(unlist(lapply(databases, function(x) {
      lapply(x$users, function(y) y$password) 
    })) %||% ""), collapse = ", "),
    
    db_names = paste(sort(unlist(lapply(databases, function(x) x$db_names)) %||% ""),
                     collapse = ", "),
    
    num_nodes = pluck(databases, "num_nodes", integer(1)),
    region = pluck(databases, "region", character(1)),
    status = pluck(databases, "status", character(1)),
    created_at = pluck(databases, "created_at", character(1)),
    
    maintenance_window_day = pluck(pluck(databases, "maintenance_window"), "day", character(1)),
    maintenance_window_hour = pluck(pluck(databases, "maintenance_window"), "hour", character(1)),
    maintenance_window_pending = pluck(pluck(databases, "maintenance_window"), "pending", logical(1)),
    
    size = pluck(databases, "size", character(1)),
    tags = paste(sort(unlist(lapply(databases, function(x) x$tags)) %||% ""),
          collapse = ", "),
    private_network_uuid = pluck(databases, "private_network_uuid", character(1)),
    project_id = pluck(databases, "project_id", character(1))
  )
  
  class(d) <- c("tbl_df", "tbl", "data.frame")
  return(d)
}
