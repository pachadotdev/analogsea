# tests for do_GET
context("do_GET")

test_that("returns expected output for sizes endpoint", {
  siz <- do_GET("sizes")

  expect_is(siz, "list")
  expect_named(siz, c("sizes", "links", "meta"))
})

test_that("returns expected output for regions endpoint", {
  regs <- do_GET("regions")

  expect_is(regs, "list")
  expect_named(regs, c("regions", "links", "meta"))
})

test_that("httr curl options work", {
  library("httr")
  expect_error(do_GET("sizes", config = timeout(seconds = 0.001)))
})
