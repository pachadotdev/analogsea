# tests for events
context("events")

source("keys.R")

test_that("incorrect input to event_id param returns error", {
  expect_error(events(3434543345345))
})
