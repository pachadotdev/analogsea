analogsea 0.4.0
===============

## NEW FEATURES

* Suite of new functions for tags: `tag()`, `tag_create()`, 
`tag_delete()`, `tag_rename()`, `tag_resource()`, 
`tag_resource_delete()`, `tags()`, and `as.tag()` (#117)
* Related to last bulllet: `droplet_delete()` gains new parameter `tag`; 
`droplets()` gains new parameter `tag`, and examples added to its man file
for tag usage.
* New functions `docklet_shinyserver()` and `docklet_shinyapp()` 
to spin up Shiny server and a Shiny app, respectively. (#100)
* New function `droplet_enable_backups()` (#110)
* New function `droplets_create()` to create many droplets at once (#112)
* New function `droplets_cost()` to calculate cost of droplets across 
one or more droplets.

## MINOR IMPROVEMENTS

* Added `floating_ip_limit` field to `account()` print method (#111)
* Improved description of `name` parameter for `droplet_create()` and
`docklet_create()`

## BUG FIXES

* Fixed problem with `docklet_create()` when port 22 is not open 
before further action is taken on the droplet. We now check if 
port 22 is open and error with informative message about waiting 
a bit for it to open (#113) thanks @fmichonneau @hrbrmstr
* Fixed problem in the `print.droplet` due to problem in `droplet_ip()` internal function (#109)
* Fix to `*_create` to allow flexibility in how often DO API is pinged. 
Previously we pinged every second, meaning you could hit your API rate limit
fastish. Now you can set an option `do.wait_time` to tweak time 
bewtween pings to check for droplet creation (or other actions). 
See <https://github.com/sckott/analogsea/issues/108#issuecomment-151519855>
for example of doing droplet creation in parallel. (#108) thanks @simecek !
* Fixed parsing bug in `sizes()` (#119)

analogsea 0.3.0
===============

## NEW FEATURES

* Released to CRAN.
