include_recipe "build-essential"
include_recipe "perl"

cpan_module "Net::Server"

src_filepath  = "#{Chef::Config['file_cache_path'] || '/tmp'}/munin-#{node['munin']['source']['version']}.tar.gz"

remote_file node['munin']['source']['url'] do
  path src_filepath
  checksum node['munin']['source']['checksum']
  source node['munin']['source']['url']
  backup false
end

user "munin" do
  system true
  shell "/bin/false"
end

