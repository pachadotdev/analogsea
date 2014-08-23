#' Get information on a single domain or all your domains.
#'
#' @export
#' @param domain (character) Required. Domain name
#' @template params
#' @examples \dontrun{
#' domains()
#' domains('sckottdrop.info')
#' }

domains <- function(domain=NULL, what="parsed", page=1, per_page=25, config=NULL)
{
  path <- if(is.null(domain)) 'domains' else sprintf('domains/%s', domain)
  do_GET(what, path = path, query = ct(page=page, per_page=per_page), parse=TRUE, config=config)
}

#' Creates a new domain name with an A record for the specified ip_address.
#'
#' @export
#' @param name (character) Required. The domain name to add to the DigitalOcean DNS management 
#' interface. The name must be unique in DigitalOcean's DNS system. The request will fail if 
#' the name has already been taken.
#' @param ip_address (character) Required. An IP address for the domain`s initial A record.
#' @template whatconfig
#' @examples \dontrun{
#' domains_new(name='tablesandchairsbunnies.info', ip_address='107.170.220.59')
#' }

domains_new <- function(name=NULL, ip_address=NULL, what="parsed", config=NULL)
{
  assert_that(!is.null(name), !is.null(ip_address))
  do_POST(what, path = 'domains', args = ct(name=name, ip_address=ip_address), parse = TRUE, config = config)
}

#' Delete a domain name.
#'
#' @export
#' @param domain (character) Required. Domain Name (e.g. domain.com), specifies the domain 
#' to destroy.
#' @param config Options passed on to httr::GET. Must be named, see examples.
#' @examples \dontrun{
#' domains_new(name='rforcats.cat', ip_address='107.170.221.51')
#' domains_delete(domain='rforcats.cat')
#' }

domains_delete <- function(domain=NULL, config=NULL)
{
  assert_that(!is.null(domain))
  do_DELETE(path = sprintf('domains/%s', domain), config = config)
}

############# Domain records
#' Get information on records for a single domain.
#'
#' @export
#' @param domain (character) Required. Domain Name (e.g. domain.com), specifies the domain for 
#' which to retrieve records.
#' @param record (integer) Optional. Specifies the domain record id to retrieve.
#' @template params
#' @examples \dontrun{
#' domains_records(domain='sckottdrop.info')
#' domains_records(domain='sckottdrop.info', record=2194418)
#' domains_records(domain='sckottdrop.info', what="raw")
#' }

domains_records <- function(domain=NULL, record=NULL, what="parsed", page=1, per_page=25, config=NULL)
{
  assert_that(!is.null(domain))
  path <- if(is.null(record)) sprintf('domains/%s/records', domain) else sprintf('domains/%s/records/%s', domain, record)
  do_GET(what, path=path, parse = TRUE, config = config)
}

#' Create a new domain name with an A record for the specified ip_address.
#'
#' @export
#' @param domain (character) Required. Domain Name (e.g. domain.com), specifies the domain for
#' which to create a record.
#' @param type (character) Required. The type of record you would like to create. 'A', 'CNAME',
#' 'NS', 'TXT', 'MX' or 'SRV'
#' @param name (character) The host name, alias, or service being defined by the record. Required 
#' for 'A', 'CNAME', 'TXT' and 'SRV' records
#' @param data (character) Variable data depending on record type. Required for 'A', 'AAAA', 
#' 'CNAME', 'MX', 'TXT', 'SRV', and 'NS' records
#' @param priority (integer) Required for 'SRV' and 'MX' records
#' @param port (integer) Required for 'SRV' records
#' @param weight (integer) Required for 'SRV' records
#' @template whatconfig
#' @examples \dontrun{
#' domains_records_new(domain='sckottdrop.info', type="TXT", data="just chillin")
#' domains_records_new(domain='sckottdrop.info', type='TXT', name='thiking', data='just chillin')
#' domains_records_new(domain='sckottdrop.info', type='TXT', name='what', data='the heck')
#' }

domains_records_new <- function(domain=NULL, type=NULL, name=NULL, data=NULL, priority=NULL,
  port=NULL, weight=NULL, what="parsed", config=NULL)
{
  assert_that(!is.null(domain))
  args <- ct(type=type, data=data, name=name, priority=priority, port=port, weight=weight)
  tmp <- do_POST(what, path=sprintf('domains/%s/records', domain), args = args, parse=TRUE, config=config)
  pdr(tmp$domain_record)
}

pdr <- function(x){
  x[sapply(x, is.null)] <- NA
  data.frame(x, stringsAsFactors = FALSE)
}

#' Edits an existing domain record.
#'
#' @export
#' @param domain (character) Required. Domain Name (e.g. domain.com), specifies the domain for
#' which to create a record.
#' @param record (integer) Required. Specifies the record id to retrieve.
#' @param name (Optional) String, required for 'A', 'CNAME', 'TXT' and 'SRV' records
#' @template whatconfig
#' @examples \dontrun{
#' domains_records_rename(domain='sckottdrop.info', record=2714634, name="new_record_name")
#' }

domains_records_rename <- function(domain=NULL, record=NULL, name=NULL, what="parsed", config=NULL)
{
  assert_that(!is.null(domain), !is.null(record))
  tmp <- do_PUT(what, path=sprintf('domains/%s/records/%s', domain, record), args=ct(name=name), parse=TRUE, config=config)
  pdr(tmp$domain_record)
}

#' Deletes the specified domain record.
#'
#' @export
#' @param domain (character) Required. Domain Name (e.g. domain.com), specifies the domain for 
#' which to retrieve records.
#' @param record (integer) Required. Specifies the record id to retrieve
#' @param config Options passed on to httr::GET. Must be named, see examples.
#' @examples \dontrun{
#' domains_records_delete(domain="sckottdrop.info", record=2192414)
#' }

domains_records_delete <- function(domain=NULL, record=NULL, config=NULL)
{
  assert_that(!is.null(domain), !is.null(record))
  do_DELETE(path = sprintf('domains/%s/records/%s', domain, record), config = config)
}
