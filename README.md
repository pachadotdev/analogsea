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

```coffee
do_auth()
```

__List of droplets__

```coffee
do_droplets_get()
```
