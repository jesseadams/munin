service 'apache2' do
  action :stop
end

include_recipe "nginx"

%w(default 000-default).each do |disable_site|
  nginx_site disable_site do
    enable false
    notifies :reload, "service[nginx]"
  end
end

munin_conf = File.join(node[:nginx][:dir], 'sites-available', 'munin.conf')

if node[:public_domain]
  case node.chef_environment
  when "production"
    public_domain = node[:public_domain]
  else
    public_domain = "#{node.chef_environment}.#{node[:public_domain]}"
  end
else
  public_domain = node[:domain]
end

template munin_conf do
  source 'nginx.conf.erb'
  mode 0644
  variables(
    :public_domain => public_domain,
    :docroot => node['munin']['docroot'],
    :log_dir => node['nginx']['log_dir'],
    :listen_port => node['munin']['web_server_port'],
    :htpasswd_file => File.join(node['munin']['basedir'], 'htpasswd.users')
  )
  if(::File.symlink?(munin_conf))
    notifies :reload, 'service[nginx]'
  end
end

nginx_site "munin.conf"
