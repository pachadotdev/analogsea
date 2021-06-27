test_that("create/delete snapshots works", {
  skip_on_cran()

  # using 25 GB SSD droplet to save time with blank space trimming for snapshot
  r <- "tor1"
  s <- "s-1vcpu-1gb"
  img <- "ubuntu-20-04-x64"

  n <- paste("ubuntu-test", gsub(":", "", gsub(".* ", "", Sys.time())), sep = "-")
  x <- droplet_create(n, region = r, size = s, image = img, wait = T)
  x <- droplet(x$id)

  # wait until all services load
  Sys.sleep(30)

  expect_equal(x$status, "active")
  expect_false(x$locked)
  expect_output(droplet_snapshot(x))

  x <- droplet(x$id)
  expect_silent(snapshot_delete(x$snapshot_ids[[1]]))
  expect_silent(droplet_delete(x))
})
