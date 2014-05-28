analogsea
=======

[![Build Status](https://api.travis-ci.org/sckott/analogsea.png)](https://travis-ci.org/sckott/analogsea)

A general purpose R interface to [Digital Ocean](https://www.digitalocean.com/)

### Digital Ocean info

+ [API docs](https://developers.digitalocean.com/)

### Quick start

__Install__

```coffee
devtools::install_github("sckott/analogsea")
library("analogsea")
```

__Authenticate__

Which in different scenarios asks for id and api key, or pulls from your `.Renviron` file if you stored them there, or pulls from the R current session environment if already stored in the current session.

```coffee
do_auth()
```

__List of droplets__

```coffee
do_droplets_get()
```

```coffee
$status
[1] "OK"

$droplets
$droplets[[1]]
$droplets[[1]]$id
[1] 1713037

$droplets[[1]]$name
[1] "stuffthings"

$droplets[[1]]$image_id
[1] 3240036

$droplets[[1]]$size_id
[1] 66

$droplets[[1]]$region_id
[1] 3

$droplets[[1]]$backups_active
[1] FALSE

$droplets[[1]]$ip_address
[1] "107.170.212.209"

$droplets[[1]]$private_ip_address
NULL

$droplets[[1]]$locked
[1] FALSE

$droplets[[1]]$status
[1] "active"

$droplets[[1]]$created_at
[1] "2014-05-25T00:34:44Z"
```
