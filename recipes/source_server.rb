
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

bash "compile_munin_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
  tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
  cd munin-#{node['munin']['source']['version']} &&
  make && make install
  EOH

  not_if do 
    node['munin']['source']['force_recompile'] == false && ::File.directory?(::File.dirname(src_filepath) + '/' + ::File.basename(src_filepath, ".tar.gz"))
  end
end

template "/etc/cron.d/munin" do
  source "munin-cron-source.erb"
  mode "0644"
  owner "root"
  group node['munin']['root']['group']
  backup 0
end
