analogsea
=========

[![Build Status](https://api.travis-ci.org/sckott/analogsea.png?branch=master)](https://travis-ci.org/sckott/analogsea)
[![Build status](https://ci.appveyor.com/api/projects/status/ll9lcqafuw338q0h/branch/master)](https://ci.appveyor.com/project/sckott/analogsea/branch/master)
[![codecov.io](https://codecov.io/github/sckott/analogsea/coverage.svg?branch=master)](https://codecov.io/github/sckott/analogsea?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/analogsea)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/analogsea)](https://cran.r-project.org/package=analogsea)

`analogsea` is an R client for version 2 of the [Digital Ocean API](https://developers.digitalocean.com/v2/). It allows you to programatically create and destroy droplets (remote computers), and install various R related tools: (these are still a work in progress):

* R (done)
* RStudio Server (done)
* RStudio Shiny Server (done)
* OpenCPU (not yet)
* Use packrat to move a project to a droplet (not yet)

## Install

Stable version from CRAN

```r
install.packages("analogsea")
```

Development version from GitHub

```r
devtools::install_github("sckott/analogsea")
library("analogsea")
```

## Create a DO account

If you don't already have one, [create a DO account](https://www.digitalocean.com/?refcode=0740f5169634). By using this link, you'll start with $10 in credits (enough for >600 hours of computing on a 1 gb machine), and if you become a digital ocean customer we'll get some DO credits for us to offset our costs for testing. Thanks :)

## Authenticate

The best way to authenticate is to generate a personal access token (https://cloud.digitalocean.com/settings/tokens/new) and save it in an environment variable called `DO_PAT`.  If you don't do this, you'll be prompted to authenticate in your browser the first time you use analogsea.

Make sure you provide digitial ocean your public key at https://cloud.digitalocean.com/ssh_keys. Github has some good advice on creating a new public key if you don't already have one: https://help.github.com/articles/generating-ssh-keys/.

## Get droplets

All droplets

```r
droplets()
```

```r
<r> droplets()
$unintrenchable
<droplet>unintrenchable (2724525)
  Status: off
  Region: San Francisco 1
  Image: Ubuntu 14.04 x64
  Size: 512mb ($0.00744 / hr)

$basipterygium
<droplet>basipterygium (2724526)
  Status: active
  Region: San Francisco 1
  Image: Ubuntu 14.04 x64
  Size: 512mb ($0.00744 / hr)
```

A single droplet. Pass in a single droplet id.

```r
droplet(2724525)
```

```r
<droplet>unintrenchable (2724525)
  Status: off
  Region: San Francisco 1
  Image: Ubuntu 14.04 x64
  Size: 512mb ($0.00744 / hr)
```

## Spin up a new droplet

To make this as dead simple as possible, you just use one function, without any parameters.

```r
droplet_create()
```

```r
Using default ssh key: Scott Chamberlain
NB: This costs $0.00744 / hour  until you droplet_delete() it
<droplet>sabaoth (2727258)
  Status: new
  Region: San Francisco 1
  Image: Ubuntu 14.04 x64
  Size: 512mb ($0.00744 / hr)
```

You can of course pass in lots of options for name of the droplet, RAM size, disk size, ssh keys, etc.  See `regions()` and `sizes()` to list available regions and sizes.

### Delete a droplet

```r
droplet_delete(1707487)
```

## Chaining

Most of the `droplet_*` functions can be chained together using the `%>%` function. For example, you can turn a droplet off, snapshot, and then turn it back on with:

```r
d %>%
   droplet_power_off() %>%
   droplet_snapshot() %>%
   droplet_power_on() %>%
```

## R

We're still working on these, but would love feedback.

## Install RStudio Server

This requires a "docklet", a droplet with docker installed:

```r
docklet_create() %>%
  docklet_rstudio()
```

This will install R, RStudio Server and it's dependencies. It will automatically pop open the RStudio server instance in your default browser, with default `username/password` of `rstudio/rstudio`.


## Meta

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
