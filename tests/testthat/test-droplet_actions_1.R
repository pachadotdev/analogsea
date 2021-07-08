test_that("install R and user creation work (Ubuntu)", {
  skip_on_cran()

  # Create droplet ----

  # using 4 CPUs + 8GB RAM droplet for faster testing
  r <- "tor1"
  s <- "s-4vcpu-8gb-intel"
  img <- "ubuntu-20-04-x64"

  n <- paste("ubuntu-test", gsub(":", "", gsub(".* ", "", Sys.time())), sep = "-")
  x <- droplet_create(n, region = r, size = s, image = img, wait = T)
  x <- droplet(x$id)

  # Install R ----

  # wait until all services load
  Sys.sleep(30)

  expect_output(ubuntu_add_swap(x, keyfile = "~/.ssh/id_rsa"))
  expect_output(ubuntu_install_r(x, keyfile = "~/.ssh/id_rsa"))

  expect_equal(x$status, "active")
  expect_false(x$locked)

  # Create users ----

  users <- list(
    user = paste0("student", 1:5),
    password = sapply(rep(8,5), create_password)
  )

  for (i in seq_along(users$user)) {
    expect_silent(
      ubuntu_create_user(x, users$user[i], users$password[i], keyfile = "~/.ssh/id_rsa")
    )
  }

  # Power off, on, reboot and delete ----

  expect_silent(droplet_power_off(x))
  expect_silent(droplet_power_on(x))
  expect_silent(droplet_reboot(x))

  expect_silent(droplet_delete(x))
})

test_that("install R and user creation work (Debian)", {
  skip_on_cran()

  # Create droplet ----

  # using 4 CPUs + 8GB RAM droplet for faster testing
  r <- "tor1"
  s <- "s-4vcpu-8gb-intel"
  img <- "debian-10-x64"

  n <- paste("debian-test", gsub(":", "", gsub(".* ", "", Sys.time())), sep = "-")
  x <- droplet_create(n, region = r, size = s, image = img, wait = T)
  x <- droplet(x$id)

  # Install R ----

  # wait until all services load
  Sys.sleep(30)

  expect_output(debian_add_swap(x, keyfile = "~/.ssh/id_rsa"))
  expect_output(debian_install_r(x, keyfile = "~/.ssh/id_rsa"))

  expect_equal(x$status, "active")
  expect_false(x$locked)

  # Create users ----

  users <- list(
    user = paste0("student", 1:5),
    password = sapply(rep(8,5), create_password)
  )

  for (i in seq_along(users$user)) {
    expect_silent(
      ubuntu_create_user(x, users$user[i], users$password[i], keyfile = "~/.ssh/id_rsa")
    )
  }

  # Power off, on, reboot and delete ----

  expect_silent(droplet_power_off(x))
  expect_silent(droplet_power_on(x))
  expect_silent(droplet_reboot(x))

  expect_silent(droplet_delete(x))
})
