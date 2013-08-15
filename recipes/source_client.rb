include_recipe "munin::source_common"

bash "compile_munin_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
  tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
  cd munin-#{node['munin']['source']['version']} &&
  make && make install-common-prime install-node-prime install-plugins-prime
  EOH

  not_if do 
    node['munin']['source']['force_recompile'] == false && ::File.directory?(::File.dirname(src_filepath) + '/' + ::File.basename(src_filepath, ".tar.gz"))
  end
end

template "/etc/init.d/munin-node" do
  source "munin-init-sysv.erb"
  mode "0755"
  owner "root"
  group node['munin']['root']['group']
  variables(
    :sbin_dir => node['munin']['source']['sbin_dir'],
    :basedir => node['munin']['source']['basedir']
  )
  backup 0
end
