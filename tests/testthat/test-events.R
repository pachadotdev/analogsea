# tests for events
context("events")

source("keys.R")

newdrop <- droplets_new(name="newdrop", size_id = 66, image_id = 3240036, region_slug = 'sfo1')
id <- newdrop$droplet$event_id
a <- events(id)
b <- events(id, what = 'raw')

test_that("events returns the correct dimensions", {
  expect_equal(length(a), 1)
  expect_equal(length(a$event), 5)

  expect_equal(length(b), 8)
})

test_that("events returns the correct class", {
  expect_is(a, "list")
  expect_is(a$event$percentage, "character")
  expect_is(b, "response")
})

test_that("incorrect input to event_id param returns error", {
  expect_error(events(3434543345345))
})
