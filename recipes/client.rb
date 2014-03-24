#
# Cookbook Name:: munin
# Recipe:: client
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
require 'socket'

service_name = node['munin']['service_name']

if node['munin']['server_list']
  munin_server_ips = node['munin']['server_list']
    .sort
    .map { |hostname| IPSocket.getaddress(hostname) }
else
  if Chef::Config[:solo]
    munin_server_ips = [node['ipaddress']]
  else
    if node['munin']['multi_environment_monitoring']
      munin_server_nodes = search(:node, "role:#{node['munin']['server_role']}")
    else
      munin_server_nodes = search(:node, "role:#{node['munin']['server_role']} AND chef_environment:#{node.chef_environment}")
    end
    munin_server_ips = munin_server_nodes
      .sort { |a, b| a['name'] <=> b['name'] }
      .map { |n| n['ipaddress'] }
  end
end

munin_server_ips << '127.0.0.1' unless munin_server_ips.include?('127.0.0.1')

package 'munin-node'

template "#{node['munin']['basedir']}/munin-node.conf" do
  source 'munin-node.conf.erb'
  mode   '0644'
  variables :munin_server_ips => munin_server_ips
  notifies :restart, "service[#{service_name}]"
end

case node['platform']
when 'arch', 'smartos'
  execute 'munin-node-configure --shell | sh' do
    not_if { Dir.entries(node['munin']['plugins']).length > 2 }
    notifies :restart, "service[#{service_name}]"
  end
end

service service_name do
  supports :restart => true
  action [:start, :enable]
end
