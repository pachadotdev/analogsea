analogsea
=======

[![Build Status](https://api.travis-ci.org/sckott/analogsea.png?branch=master)](https://travis-ci.org/sckott/analogsea)
[![Build status](https://ci.appveyor.com/api/projects/status/ll9lcqafuw338q0h/branch/master)](https://ci.appveyor.com/project/sckott/analogsea/branch/master)

`analogsea` is an R client for version 2 of the [Digital Ocean API](https://developers.digitalocean.com/v2/) API. It allows you to progmatically create and destroy droplets (remote computes), and install various R related tools: (these are still a work in progress):

* R
* RStudio Server
* RStudio Shiny Server
* OpenCPU
* Use packrat to move a project to a droplet

## Quick start

### Install

```r
# install.packages("devtools")
devtools::install_github("sckott/analogsea")
library("analogsea")
```

### Create a DO account

If you don't already have create, [create a DO account](https://www.digitalocean.com/?refcode=0740f5169634). Use this referral link to generate some DO credits for us to offset our costs for testing the package. Thanks :)

### Authenticate

The best way to authenticate is to generate a [personal access token](https://cloud.digitalocean.com/settings/tokens/new) and save it in an environment variable called `DO_PAT`.  If you don't do this, you'll be prompted to authenticate in your browser the first time you use analogsea.

Make sure you provide digitial ocean your public key at <https://cloud.digitalocean.com/ssh_keys>. 

### Get droplets

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

### Spin up a new droplet

To make this as dead simple as possible, you just use one function, without any parameters.

```r
droplet_new()
```

```r
Using default ssh key: Scott Chamberlain
NB: This costs $0.00744 / hour  until you droplete_delete() it
<droplet>sabaoth (2727258)
  Status: new
  Region: San Francisco 1
  Image: Ubuntu 14.04 x64
  Size: 512mb ($0.00744 / hr)
```

You can of course pass in lots of options for name of the droplet, RAM size, disk size, ssh keys, etc.  See `regions()` and `sizes()` to list available regions and sizes.

#### Delete a droplet

```r
droplet_delete(1707487)
```

### Chaining

Most of the `droplet_*` functions can be chained together using the `%>%` function. For example, you can turn a droplet off, snapshot, and then turn it back on with:

```r
d %>% 
   droplet_power_off() %>%
   droplet_snapshot() %>%
   droplet_power_on() %>%
```

## R

We're still working on these, but would love feedback.

### Install RStudio Server

You of course have to have an active droplet to do this. Once you have one, pass in a droplet id.

```r
do_install(1746479, what='rstudio_server')
```

This will install R, RStudio Server and it's dependencies. It will automatically pop open the RStudio server instance in your default browser, with default `username/password` of `rstudio/rstudio`.

Other options include:

* Install R using `what='r'`
* Install RStudio Shiny Server using `what='shiny_server'`
* Install common dependencies, e.g. `deps=c('curl','xml')`
* Install OpenCPU using `what='opencpu'` __not working yet__
