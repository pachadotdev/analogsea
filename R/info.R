#' @title Functions for DigitalOcean (DO) droplets
#'
#' @description There's a lot of functions for working with droplets.
#' Here's a breakdown of what they all do.
#'
#' @name droplet_functions
#' @section Documentation:
#'
#' - DigitalOcean docs overview:
#' <https://developers.digitalocean.com/documentation/>
#' - DigitalOcean API docs:
#' <https://developers.digitalocean.com/documentation/v2/>
#'
#' @section Functions:
#'
#' The main functions for creating/deleting droplets:
#'
#' - [droplet()]: get a droplet object from a droplet ID
#' - [droplet_create()]: create a droplet
#' - [droplets_create()]: create two or more droplets
#' - [droplet_delete()]: delete a droplet
#' - [droplets()]: get your droplets
#' - [as.droplet()]: coerce various things to droplet objects
#'
#' Modify a droplet:
#'
#' - [droplet_resize()]: resize a droplet to a different size
#' - [droplet_rebuild()]: reinstall a droplet with a different image
#' - [droplet_rename()]: rename a droplet
#' - [droplet_change_kernel()]: change droplet to a new kernel
#'
#' Take and restore snapshots:
#'
#' - [droplet_snapshot()]: make a snapshot of a droplet
#' - [droplet_snapshots_list()]: list snapshots on a droplet
#' - [droplet_backups_list()]: list droplet backups
#' - [droplet_restore()]: Restore a droplet with a previous image or snapshot
#'
#' ssh interactions with droplets:
#'
#' - [droplet_ssh()]: Remotely execute code on your droplet via ssh
#' - [droplet_upload()]: Upload files to your droplet via ssh
#' - [droplet_download()]: Download files from your droplet via ssh
#'
#' Perform various actions on droplets:
#'
#' - [droplet_actions()]: retrieve a droplet action or list all actions
#' associated with a droplet
#' - [droplet_disable_backups()]: Disables backups for a droplet
#' - [droplet_do_actions()]: Perform actions on one or more droplets associated with a tag
#' - [droplet_enable_backups()]: Enables backups for a droplet
#' - [droplet_enable_ipv6()]: Enable IPv6 networking on an existing droplet (within
#'   a region that has IPv6 available)
#' - [droplet_enable_private_networking()]: Enable private networking on an existing
#'   droplet (within a region that has private networking available)
#' - [droplet_execute()]: Execute R code on a droplet
#' - [droplet_kernels_list()]:  List all available kernels for a droplet
#' - [droplet_neighbors()]: List a droplet's neighbors on the same physical server
#' - [droplet_power_cycle()]: power cycle a droplet. will turn off the droplet and
#'   then turn it back on
#' - [droplet_power_off()]: Shutdown a running droplet. The droplet will remain in
#'   your account and you will continue to be charged for it
#' - [droplet_power_on()]: Turn on a droplet that's turned off
#' - [droplet_reboot()]: reboot a droplet. This is the preferred method to use if
#'   a server is not responding
#' - [droplet_reset_password()]: reset the root password for a droplet
#' - [droplet_reuse()]: Reuse a droplet or image by name, creating a new droplet
#' - [droplet_shutdown()]: Shutdown a running droplet. The droplet will remain in
#'   your account and you will continue to be charged for it.
#' - [droplet_upgrade()]: Migrate a droplet - NOT SURE IF THIS STILL WORKS OR NOT
#' - [droplet_upgrades_list()]: List all droplets that are scheduled to be upgraded
#' - [droplet_wait()]: Wait for a droplet to be ready. mostly used internally
#' - [droplets_cost()]: Calculate cost across droplets
#'
#' Freeze/thaw droplets:
#'
#' - [droplet_freeze()]: power off a droplet, snapshots to create an image, and deletes the
#'   droplet
#' - [droplet_thaw()]: takes an image and turns it into a running droplet
#'
#' @section Working with Docker:
#'
#' We named a DO droplet with the Docker application installed a "docklet"
#' for convienence
#'
#' The main two functions for creating docklets:
#'
#' - [docklet_create()]: create a docklet (a droplet using the docker image)
#' - [docklets_create()]: create many docklets
#'
#' Running docker commands on your docklet:
#'
#' - [docklet_images()]: list docker images on your docklet
#' - [docklet_ps()]: list running docker containers
#' - [docklet_pull()]: pull a docker image to your docklet
#' - [docklet_rm()]: remove a docker image from your docklet
#' - [docklet_run()]: run a docker command on your docklet
#' - [docklet_stop()]: stop a running docker container
#' - [docklet_docker()]: low level fxn for running docker commands on your,
#'   not realy intended for public use
#'
#' Install RStudio things:
#'
#' - [docklet_rstudio()]: install RStudio on your docklet using
#' Rocker images (<https://hub.docker.com/u/rocker>)
#' - [docklet_rstudio_addusers()]: add users to an RStudio docker image
#' - [docklet_shinyserver()]: install Shiny server on your docklet using
#' Rocker images (<https://hub.docker.com/u/rocker>)
#' - [docklet_shinyapp()]: install a Shiny app on your Shiny server docker
#' container
NULL

#' @title Functions for spaces
#' 
#' @description There's many functions for working with spaces.
#' Here's a breakdown of what they all do.
#'
#' @name spaces_functions
#' @section Documentation:
#'
#' - DigitalOcean docs overview:
#' <https://developers.digitalocean.com/documentation/>
#' - DigitalOcean spaces API docs:
#' <https://developers.digitalocean.com/documentation/spaces/>
#'
#' @section Functions:
#' 
#' The main functions for creating/deleting spaces:
#'  
#' - [space_create()]: Create a Space
#' - [space_delete()]: Delete a Space
#' 
#' Operations on spaces:
#'
#' - [as.space()]: Coerce an object to a Space
#' - [summary()]: Get a summary of a Space object
#' - [space_location()]: Get the region of a Space
#' - [spaces()]: List all spaces
#' 
#' Objects:
#' 
#' - [spaces_object_copy()]: Copy an Object from one Space to another
#' - [spaces_object_get()]: Retrieve an Object from a Space
#' - [spaces_object_head()]: Get information about an Object
#' - [spaces_object_put()]: Upload an Object to a Space
#' - [spaces_object_delete()]: Delete an Object from a Space
#' - [space_size()]: Get the size of all Objects in a Space
#' - [space_list()]: List the objects in a Space
#' - [space_files()]: Get number of objects in a Space
#' 
#' Access Control List's:
#' 
#' - [spaces_acl_get()]: Retrieve an Object's Access Control List (ACL)
#' - [spaces_acl_put()]: Set an Object's Access Control List (ACL)
NULL
