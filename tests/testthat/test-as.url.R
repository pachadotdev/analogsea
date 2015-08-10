# tests for as.url
context("as.url and url")

test_that("as.url returns expected output for sizes endpoint", {
  aa <- as.url("sizes")

  expect_is(aa, "character")
  expect_equal(aa, "https://api.digitalocean.com/v2/sizes")
})

test_that("as.url returns expected output for regions endpoint", {
  bb <- as.url("regions")

  expect_is(bb, "character")
  expect_equal(bb, "https://api.digitalocean.com/v2/regions")
})

test_that("as.url works for a do_url class object", {
  cc <- as.url(url())

  expect_is(cc, "do_url")
  expect_equal(cc[[1]], "https://api.digitalocean.com/v2")
})

test_that("as.url fails well with wrong input", {
  expect_error(as.url(5), "no applicable method")
  expect_error(as.url(list(5)), "no applicable method")
  expect_error(as.url(data.frame(NULL)), "no applicable method")
})
