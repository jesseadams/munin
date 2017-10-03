#
# Cookbook Name:: munin
# Recipe:: server
#
# Copyright 2010-2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unless node['munin']['public_domain']
  if node['public_domain']
    case node.chef_environment
      when 'production'
        public_domain = node['public_domain']
      else
        if node['munin']['multi_environment_monitoring']
          public_domain = node['public_domain']
        else
          env = node.chef_environment =~ /_default/ ? 'default' : node.chef_environment
          public_domain = "#{env}.#{node['public_domain']}"
        end
    end
  else
    public_domain = node['domain']
  end
  node.default['munin']['public_domain'] = "munin.#{public_domain}"
end

web_srv = node['munin']['web_server'].to_sym
case web_srv
  when :apache
    include_recipe 'munin::server_apache'
    web_group = node['apache']['group']
  when :nginx
    include_recipe 'munin::server_nginx'
    web_group = node['nginx']['group']
  when :openresty
    include_recipe 'munin::server_openresty'
    web_group = node['nginx']['group']
  else
    fail 'Unsupported web server type provided for munin. Supported: apache or nginx'
end

include_recipe 'munin::client'

munin_client_nodes = []
if node['munin']['client_list']
  munin_client_nodes = node['munin']['client_list']
else
  if Chef::Config[:solo]
    munin_client_nodes = [node]
  else
    search_query = 'munin:[* TO *]'
    if node['munin']['client_role']
      search_query = "roles:#{node['munin']['client_role']}"
    end

    if node['munin']['multi_environment_monitoring']
      if node['munin']['multi_environment_monitoring'].kind_of?(Array)
        node['munin']['multi_environment_monitoring'].each do |searchenv|
          search(:node, "#{search_query} AND chef_environment:#{searchenv}").each do |n|
            munin_client_nodes << n
          end
        end
      else
        munin_client_nodes = search(:node, search_query)
      end
    else
      munin_client_nodes = search(:node, "#{search_query} AND chef_environment:#{node.chef_environment}")
    end
  end
end

if munin_client_nodes.empty?
  Chef::Log.info 'No nodes returned from search, using this node so munin configuration has data'
  munin_client_nodes = [node]
end

systems = []
munin_client_nodes.each do |node|
  system = node
  if system['fqdn'].empty?
    ipaddress['fqdn'] = system['ipaddress']
  end
  systems.push(system)
end
systems.sort!

template "#{node['munin']['basedir']}/munin.conf" do
  source 'munin.conf.erb'
  mode '0644'
  variables(
      :munin_nodes => systems
  )
end

case node['platform']
  when 'freebsd'
    package 'munin-master'
  else
    package 'munin'
end

case node['platform']
  when 'arch'
    cron 'munin-graph-html' do
      command '/usr/bin/munin-cron'
      user 'munin'
      minute '*/5'
    end
  when 'freebsd'
    cron 'munin-graph-html' do
      command '/usr/local/bin/munin-cron'
      user 'munin'
      minute '*/5'
      ignore_failure true
    end
  else
    cookbook_file '/etc/cron.d/munin' do
      source 'munin-cron'
      mode '0644'
      owner 'root'
      group node['munin']['root']['group']
      backup 0
    end
end

directory "#{node['munin']['basedir']}/munin-conf.d" do
  action :create
end

case node['munin']['server_auth_method']
  when 'openid'
    if web_srv == :apache
      include_recipe 'apache2::mod_auth_openid'
    else
      fail 'OpenID is unsupported on non-apache installs'
    end
  when 'open'
# do nothing
  else
    sysadmins = []
    if Chef::Config[:solo]
      sysadmins = data_bag('users').map {|user| data_bag_item('users', user)}
    else
      sysadmins = search(:users, 'groups:sysadmin')
    end

    template "#{node['munin']['basedir']}/htpasswd.users" do
      source 'htpasswd.users.erb'
      owner 'munin'
      group web_group
      mode '0644'
      variables(
          :sysadmins => sysadmins
      )
    end
end

directory node['munin']['docroot'] do
  owner 'munin'
  group 'munin'
  mode '0755'
end
