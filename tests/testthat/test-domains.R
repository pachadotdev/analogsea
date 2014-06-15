# tests for domains
context("domains")

a <- domains()
b <- domains(what = 'raw')

domnane <- paste0(paste(sample(letters, size = 15, replace = FALSE), collapse = ""), ".info")
c <- domains_new(name = domnane, ip_address = "123.456.789")
d <- domains_destroy(domain_id=domnane)

domnane2 <- paste0(paste(sample(letters, size = 15, replace = FALSE), collapse = ""), ".info")
e <- domains_new(name = domnane2, ip_address = "123.456.123")
f <- domains_new_record(domain_id=domnane2, record_type="TXT", data="what what")
g <- domains_edit_record(domain_id=domnane2, record_id=f$record$id, record_type="TXT", data="edited text")
h <- domains_destroy_record(domain_id=domnane2, record_id=f$record$id)

i <- domains_records(domain_id = domnane2)

test_that("domains returns the correct class", {
  expect_is(a, "list")
  expect_is(b, "response")
  expect_is(c, "list")
  expect_is(d, "list")
  expect_is(e, "list")
  expect_is(f, "list")
  expect_is(g, "list")
  expect_is(h, "list")
})

test_that("incorrect input to what param returns NULL", {
  expect_error(domains_records("asfasd"))
})
