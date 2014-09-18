#
# Original Author:: Joshua Sierles <joshua@37signals.com>
# Original Author:: Tim Smith <tsmith@limelight.com>
# Original Source:: https://github.com/tas50/nagios/blob/master/libraries/default.rb
#
# Cookbook Name:: munin
# Library:: default
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

# decide whether to use internal or external IP addresses for this node
# if the munin server is not in the cloud, always use public IP addresses for cloud nodes.
# if the munin server is in the cloud, use private IP addresses for any
#   cloud servers in the same cloud, public IPs for servers in other clouds
#   (where other is defined by node['cloud']['provider'])
# if the cloud IP is nil then use the standard IP address attribute.  This is a work around
#   for OHAI incorrectly identifying systems on Cisco hardware as being in Rackspace
def ip_to_monitor(monitored_host, server_host = node)
  # if interface to monitor is specified implicitly use that
  if node['munin']['monitoring_interface'] && node['network']["ipaddress_#{node['munin']['monitoring_interface']}"]
    node['network']["ipaddress_#{node['munin']['monitoring_interface']}"]
  # if server is not in the cloud and the monitored host is
  elsif server_host['cloud'].nil? && monitored_host['cloud']
    monitored_host['cloud']['public_ipv4'].include?('.') ? monitored_host['cloud']['public_ipv4'] : monitored_host['ipaddress']
  # if server host is in the cloud and the monitored node is as well, but they are not on the same provider
  elsif server_host['cloud'] && monitored_host['cloud'] && monitored_host['cloud']['provider'] != server_host['cloud']['provider']
    monitored_host['cloud']['public_ipv4'].include?('.') ? monitored_host['cloud']['public_ipv4'] : monitored_host['ipaddress']
  else
    monitored_host['ipaddress']
  end
end

