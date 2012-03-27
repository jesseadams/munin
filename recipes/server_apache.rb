node['apache']['default_modules'] << 'expires' if platform?("redhat", "centos", "scientific", "fedora")

include_recipe "apache2"
include_recipe "apache2::mod_rewrite"

apache_site "000-default" do
  enable false
end

template "#{node[:apache][:dir]}/sites-available/munin.conf" do
  source "apache2.conf.erb"
  mode 0644
  variables(:public_domain => public_domain, :docroot => node['munin']['docroot'])
  if ::File.symlink?("#{node[:apache][:dir]}/sites-enabled/munin.conf")
    notifies :reload, resources(:service => "apache2")
  end
end

apache_site "munin.conf"
