Description
===========

Installs and configures Munin for a server and for clients using Chef
Server search capabilities.

Requirements
============

Requires Chef 0.10.0+ for Chef environments. Requires a Chef Server
for performing node searches.

The monitoring server that uses this recipe should have a role named
'`monitoring`'. This is configurable with an attribute (see below). The
recipes use search, and narrow the results to nodes in the same
`chef_environment`.

## Platform

* Debian/Ubuntu
* Red Hat 5.7, 6.1
* ArchLinux

## Cookbooks

* apache2

Not required (users can simply be in a data bag and the recipe will
search), but useful for setting the openid list (see __OpenID
Authentication__, below).

* users (see __Data Bags__)

Not required, but recommended to install perl cpan modules for munin plugins

* perl
* nginx

Attributes
==========

* `node['munin']['web_server_port']` - port that the munin vhost runs
  on, default 80
* `node['munin']['sysadmin_email']` - default email address for
  serveradmin in vhost.
* `node['munin']['server_auth_method']` - the authentication method to
  use, default is openid. Any other value will use htauth basic with
  an htpasswd file.
* `node['munin']['multi_environment_monitoring']` - allow
   multi-environment monitoring.  Default is false.
* `node['munin']['server_role']` - role of the munin server. Default
  is monitoring.
* `node['munin']['docroot']` - document root for the server apache
  vhost. on archlinux, the default is `/srv/http/munin`, or
  `/var/www/munin` on other platforms.
* `node['munin']['web_server']` - supports apache or nginx, default is
  "apache"
* `node['munin']['public_domain']` - override munin domain.
* `node['munin']['max_processes']` - Maximum number of simultaneous
  Munin-update processes. When not set, munin will use as many as
  necessary. Default is to use as many as necessary.
* `node['munin']['max_graph_jobs']` - Maximum number of parallel
  processes used by munin-graph when calling rrdgraph, default is "6"
* `node['munin']['max_cgi_graph_jobs']` - Maximum number of parallel
  munin-cgi-graph or munin-fastcgi-graph jobs, default is "6"

Recipes
=======

## client

The client recipe installs munin-node package and starts the service.
It also searches for a node with the role for the munin server, by
default `node['munin']['server_role']`. On Archlinux, it builds the
list of plugins to enable.

## server

The server recipe will set up the munin server with Apache. It will
create a cron job for generating the munin graphs, search for any
nodes that have munin attributes (`node['munin']`), and use those
nodes to connect for the graphs.

Optionally the server can be setup with NGINX.

Data Bags
=========

Create a `users` data bag that will contain the users that will be
able to log into the Munin webui. Each user can use htauth with a
specified password, or an openid. Users that should be able to log in
should be in the sysadmin group. Example user data bag item:

    {
      "id": "munin",
      "groups": "sysadmin",
      "htpasswd": "hashed_htpassword",
      "openid": "http://munin.myopenid.com/"
    }

When using `server_auth_method` 'openid', use the openid in the data bag
item. Any other value for this attribute (e.g., "htauth", "htpasswd",
etc) will use the htpasswd value as the password in
`/etc/munin/htpasswd.users`.

*The openid must have the http:// and trailing /*. See __OpenID
 Authentication__ below for more information.

The htpasswd must be the hashed value. Get this value with htpasswd:

    % htpasswd -n -s munin
    New password:
    Re-type new password:
    munin:{SHA}oCagzV4lMZyS7jl2Z0WlmLxEkt4=

For example use the `{SHA}oCagzV4lMZyS7jl2Z0WlmLxEkt4=` value in the data bag.

Usage
=====

Create a role named `monitoring` that includes the munin::server
recipe in the run list. Adjust the docroot to suit your environment.

    % cat roles/monitoring.rb
    name "monitoring"
    description "The monitoring server"
    run_list(
      "recipe[munin::server]"
    )

Apply this role to a node and it will be the munin server. Optionally
create a DNS entry for it as munin, that will be used in the Apache
vhost.

Use Chef 0.10's environments. For example, create a "production"
environment Ruby DSL file and upload it to the Chef Server

    % cat environments/production.rb
    name "production"
    description "Nodes in production"
    % knife environment from file production.rb

Clients will automatically search for the server based on the value of
the `node['munin']['server_role']` attribute in the same environment.
If you don't use `monitoring` as the role name, change it in a role
that is applied to any nodes that get the `munin::client` recipe.

## OpenID Authentication

The recipe `apache2::mod_auth_openid` is updated to a version of the
module that apparently does not support the `AuthOpenIDUserProgram`
directive anymore. The virtual host file has been updated to use the
Apache HTTPD `require user` directive, with a concatenated list from
`node['apache']['allowed_openids']`. This value must be an array of
OpenIDs. Use of the `users::sysadmins` recipe will set this up based
on data bag search results.

## Custom Plugins

This section describes how to add custom munin plugins.

The munin cookbook now has a definition that can be used to enable a
new plugin for data gathering on a client. If an existing munin plugin
is desired, call the definition

    munin_plugin "nfs_client"

By default the plugin file name is the name parameter here. Specify
the plugin parameter to use something else.

    munin_plugin "nfs_client"
      plugin "nfs_client_"
    end

This creates a symlink from the plugins distribution directory,
 `/usr/share/munin/plugins` to the enabled plugins directory,
 `/etc/munin/plugins`, and once the server poller picks it up will
 have new graph data for that plugin. See the plugins distribution
 directory for available plugins or add your own.

If a custom plugin is required, add the plugin file to the munin
cookbook in `site-cookbooks/munin/files/default/plugins`. Call the
definition specifying that the plugin file should be downloaded from
the cookbook.

    munin_plugin "nfs_client_custom"
      create_file true
    end

By default in both cases, the plugin is enabled. If a plugin should be
disabled, use the `enable` parameter

    munin_plugin "nfs_client_custom"
      enable false
    end

Some plugins may require other configuration. For example, to use the
memcache plugins, you'll need the `Cache::Memcache` cpan module
installed, and use the `munin_plugin` definition. The perl cookbook
from opscode includes a definition to handle this easily.

    cpan_module "Cache::Memcached"

Then for example in your memcache recipe

    %w(
      memcached_bytes_
      memcached_connections_
      memcached_hits_
      memcached_items_
      memcached_requests_
      memcached_responsetime_
      memcached_traffic_
    ).each do |plugin_name|
      munin_plugin plugin_name do
        plugin "#{plugin_name}#{node[:ipaddress].gsub('.','_')}_#{node[:memcached][:port]}"
        create_file true
      end
    end

License and Author
==================

- Author:: Nathan Haneysmith <nathan@opscode.com>
- Author:: Joshua Timberman <joshua@opscode.com>

- Copyright 2009-2013, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
