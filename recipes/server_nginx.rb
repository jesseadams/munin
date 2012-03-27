include_recipe "nginx"

nginx_site 'default' do
  enable false
end

munin_conf = File.join(node[:nginx][:dir], 'sites-available', 'munin.conf')

template munin_conf do
  source 'nginx.conf.erb'
  mode 0644
  variables(
    :public_domain => public_domain,
    :docroot => node['munin']['docroot'],
    :log_dir => node['nginx']['log_dir'],
    :listen_port => 80,
    :htpasswd_file => File.join(node['munin']['basedir'], 'htpasswd.users')
  )
  if(::File.symlink(munin_conf))
    notifies :reload, 'service[nginx]'
  end
end

nginx_site "munin.conf"
