#
# Cookbook Name:: munin
# Recipe:: client
#
# Copyright 2010, Opscode, Inc.
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

if Chef::Config[:solo]
  munin_servers = [node]
else
  if node['munin']['multi_environment_monitoring']
    munin_servers = search(:node, "role:#{node['munin']['server_role']}")
  else  
    munin_servers = search(:node, "role:#{node['munin']['server_role']} AND chef_environment:#{node.chef_environment}")
  end
end

service_name = node['munin']['service_name']

if node['munin']['install_method'] == 'package'
  package "munin-node"

  basedir = node['munin']['basedir']
  log_dir = node['munin']['log_dir']
  plugins_dir = node['munin']['plugins_dir']
elsif node['munin']['install_method'] == "source"
  include_recipe "munin::source_client"

  basedir = node['munin']['source']['basedir']
  log_dir = node['munin']['source']['log_dir']
  plugins_dir = node['munin']['source']['plugins_dir']
end

template "#{basedir}/munin-node.conf" do
  source "munin-node.conf.erb"
  mode 0644
  variables(
    :munin_servers => munin_servers,
    :log_dir => log_dir
  )
  notifies :restart, "service[#{service_name}]"
end

service service_name do
  supports :restart => true
  action :enable
end

case node['platform']
when "arch", "smartos"
  execute "munin-node-configure --shell | sh" do
    not_if { Dir.entries(plugins_dir).length > 2 }
    notifies :restart, "service[#{service_name}]"
  end
end
