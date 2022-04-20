# tests for events
context("events")

test_that("incorrect input to event_id param returns error", {
	skip_on_cran()

  expect_error(events(3434543345345))
})
