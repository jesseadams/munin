include_recipe "nginx"

%w(default 000-default).each do |disable_site|
  nginx_site disable_site do
    enable false
    notifies :reload, "service[nginx]"
  end
end

munin_conf = File.join(node['nginx']['dir'], 'sites-available', 'munin.conf')

if node['munin']['install_method'] == "source"
  docroot = node['munin']['source']['docroot']
  log_dir = node['munin']['source']['log_dir']
  basedir = node['munin']['source']['basedir']
else
  docroot = node['munin']['docroot']
  log_dir = node['munin']['log_dir']
  basedir = node['munin']['basedir']
end

template munin_conf do
  source 'nginx.conf.erb'
  mode 0644
  variables(
    :public_domain => node['munin']['public_domain'],
    :nginx_fastcgi_support => node['munin']['nginx_fastcgi_support'],
    :docroot => docroot,
    :log_dir => log_dir,
    :listen_port => node['munin']['web_server_port'],
    :htpasswd_file => File.join(basedir, 'htpasswd.users')
  )
  if(::File.exist?(munin_conf))
    notifies :reload, 'service[nginx]'
  end
end

nginx_site "munin.conf"
