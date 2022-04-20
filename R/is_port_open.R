#' Test to see if a TCP port is open
#'
#' @param host ip or host name to connect to
#' @param port port to connect to
#' @param timeout how many secs to let it try
#' @noRd
#' @author Bob Rudis \email{bob@@rudis.net}
#' @examples \dontrun{
#' is_port_open("httpbin.org", 80)
#' is_port_open("httpbin.org", 22)
#' }
is_port_open <- function(host, port=22, timeout=1) {

  WARN <- getOption("warn")
  options(warn = -1)

  socketConnection

  con <- try(socketConnection(host, port, blocking = TRUE, timeout = timeout),
             silent = TRUE)

  if (!inherits(con, "try-error")) {
    close(con)
    options(warn = WARN)
    TRUE
  } else {
    options(warn = WARN)
    FALSE
  }

}
