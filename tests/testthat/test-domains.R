# tests for domains
context("domains")

source("keys.R")

test_that("incorrect input to what param returns NULL", {
  expect_error(domains_records("asfasd"))
})
