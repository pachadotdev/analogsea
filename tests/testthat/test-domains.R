# tests for domains
context("domains")

test_that("incorrect input to what param returns NULL", {
  expect_error(domains_records("asfasd"))
})
