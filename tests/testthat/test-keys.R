# tests for keys
context("keys")

source("keys.R")

a <- keys()
b <- keys(what = 'raw')
c <- keys(ssh_key_id=89103)

test_that("keys returns the correct dimensions", {
  expect_equal(length(a), 1)
  expect_equal(names(a), 'ssh_keys')

  expect_equal(length(b), 8)

  expect_equal(length(c), 1)
})

test_that("keys returns the correct class", {
  expect_is(a, "list")
  expect_is(a$ssh_keys[[1]]$id, "numeric")
  expect_is(b, "response")
  expect_is(c, "list")
})

test_that("incorrect input to what param returns NULL", {
  expect_error(keys("asfasd"))
  expect_error(keys(ssh_key_id=891032343))
})
