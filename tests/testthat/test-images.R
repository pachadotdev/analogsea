# tests for images
context("images")

source("keys.R")

a <- head(images())
b <- images(filter='my_images')
c <- images(what='raw')
d <- images(image_id=3209452)

test_that("images returns the correct dimensions", {
  expect_equal(NCOL(a), 11)
  expect_identical(names(b), c('id','name','slug','distribution','public','sfo1'))

  expect_equal(NCOL(b), 6)

  expect_equal(length(c), 8)

  expect_equal(length(d), 7)
})

test_that("images returns the correct class", {
  expect_is(a, "data.frame")
  expect_is(a$slug, "character")
  expect_is(b, "data.frame")
  expect_is(c, "response")
  expect_is(d, "list")
})

test_that("incorrect input to what param returns NULL", {
  expect_null(images(what = "asfasd"))
  expect_error(images(image_id = 343454545))
})
