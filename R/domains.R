#' Get information on a single domain or all your domains.
#'
#' @export
#' @param domain_id Domain ID
#' @template params
#' @examples \dontrun{
#' domains()
#' domains(316128)
#' domains(what="raw")
#' }

domains <- function(domain_id=NULL, what="parsed", ...)
{
  path <- if(is.null(domain_id)) 'domains' else sprintf('domains/%s', domain_id)
  do_GET(what, FALSE, path, ...)
}

#' Creates a new domain name with an A record for the specified ip_address.
#'
#' @export
#' @param name Name of the domain (e.g., stuff.com)
#' @param ip_address An IP address for the domain`s initial a record.
#' @template params
#' @examples \dontrun{
#' domains_new(name='tablesandchairsbunnies.info', ip_address='107.170.220.59')
#' domains_new(what="raw")
#' }

domains_new <- function(name=NULL, ip_address=NULL, what="parsed", ...)
{
  assert_that(!is.null(name))
  assert_that(!is.null(ip_address))
  do_GET(what, FALSE, 'domains/new', ct(name=name, ip_address=ip_address), ...)
}

#' Delete a domain name
#'
#' @export
#' @param domain_id Integer or Domain Name (e.g. domain.com), specifies the domain to destroy.
#' @template params
#' @examples \dontrun{
#' domains_destroy(domain_id=316384)
#' domains_destroy(domain_id='tablesandchairsbunnies.info')
#' }

domains_destroy <- function(domain_id=NULL, what="parsed", ...)
{
  assert_that(!is.null(domain_id))
  do_GET(what, FALSE, sprintf('domains/%s/destroy', domain_id), ...)
}


#' Create a new domain name with an A record for the specified ip_address.
#'
#' @export
#' @param domain_id (required) Integer or Domain Name (e.g. domain.com), specifies the domain for
#' which to create a record.
#' @param record_type (required) String, the type of record you would like to create. 'A', 'CNAME',
#' 'NS', 'TXT', 'MX' or 'SRV'
#' @param data (required) String, this is the value of the record
#' @param name (Optional) String, required for 'A', 'CNAME', 'TXT' and 'SRV' records
#' @param priority (Optional) Integer, required for 'SRV' and 'MX' records
#' @param port (Optional) Integer, required for 'SRV' records
#' @param weight (Optional) Integer, required for 'SRV' records
#' @template params
#' @examples \dontrun{
#' domains_destroy(domain_id=316384)
#' domains_destroy(domain_id='tablesandchairsbunnies.info')
#' }

domains_new_record <- function(domain_id=NULL, record_type=NULL, data=NULL, name=NULL, priority=NULL,
  port=NULL, weight=NULL, what="parsed", ...)
{
  assert_that(!is.null(domain_id))
  path <- sprintf('domains/%s/records/new', domain_id)
  args <- ct(record_type=record_type, data=data, name=name, priority=priority, port=port, weight=weight)
  do_GET(what, FALSE, path, args, ...)
}
