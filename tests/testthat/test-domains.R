# tests for domains
context("domains")

test_that("incorrect input to what param returns NULL", {
	skip_on_cran()

  expect_error(domain_records("asfasd"), "The resource you were accessing could not be found")
})
