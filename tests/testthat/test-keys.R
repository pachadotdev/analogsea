# tests for keys
context("keys")

a <- keys()
b <- keys(what = 'raw')
c <- keys(ssh_key_id=89103)

test_that("keys returns the correct dimensions", {
  expect_equal(NCOL(a), 8)
  expect_equal(names(a), c('id','name','slug','memory','cpu','disk','cost_per_hour','cost_per_month'))

  expect_equal(length(b), 8)
})

test_that("keys returns the correct class", {
  expect_is(a, "data.frame")
  expect_is(a$cost_per_hour, "numeric")
  expect_is(b, "response")
})

test_that("incorrect input to what param returns NULL", {
  expect_null(keys("asfasd"))
})
