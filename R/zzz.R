list_to_object <- function(x, singular, plural = paste0(singular, "s"),
                  name = "name", class = singular) {
  if (!is.null(x[[plural]])) {
    objs <- lapply(x[[plural]], structure, class = class)
    if (!is.null(name)) {
      names(objs) <- pluck(x[[plural]], name, character(1))
    }
    objs
  } else if (!is.null(x[[singular]])) {
    structure(x[[singular]], class = class)
  } else {
    stop("Don't know how to coerce this list to a ", class , call. = FALSE)
  }
}

mssg <- function(x, y) if (x) message(y)

writefile <- function(filename, installstring){
  installrfile = filename
  fileConn <- file(installrfile)
  writeLines(installstring, fileConn)
  close(fileConn)
}

cli_tools <- function(ip){
  tmp <- Sys.which(c("ssh","scp"))
  if (any(tmp == "")) {
    nf <- paste0(names(tmp)[tmp == ""], collapse = ", ")
    stop(sprintf("\n%s not found on your computer\nInstall the missing tool(s) and try again", nf))
  }
}

ascompact <- function(x) Filter(Negate(is.null), x)

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

`%||%` <- function(a, b) if (is.null(a)) b else a

unbox <- function(x) {
  if (is.null(x)) x else jsonlite::unbox(x)
}

get_price <- function(slug){
  sz <- sizes()
  as.list(sz[ sz$slug == slug , c("price_monthly","price_hourly") ])
}

al <- function(x){
  stopifnot(is.logical(x))
  if (x) 'true' else 'false'
}
