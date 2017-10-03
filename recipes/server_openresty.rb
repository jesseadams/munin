#
# Cookbook Name:: munin
# Recipe:: server_nginx
#
# Copyright 2013, Opscode, Inc.
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

service 'apache2' do
  action :stop
end

include_recipe 'openresty::default'

node.default['openresty']['default_site_enabled'] = false

nginx_sites_dir = "#{node['openresty']['dir']}/sites-available"
munin_conf = "#{nginx_sites_dir}/munin.conf"

template munin_conf do
  source   'nginx.conf.erb'
  mode     '0644'
  notifies :reload, 'service[nginx]' if ::File.symlink?(munin_conf)
end

link "#{node['openresty']['dir']}/sites-enabled/munin.conf" do
  to "#{nginx_sites_dir}/munin.conf"
end
