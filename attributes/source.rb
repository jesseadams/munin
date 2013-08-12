include_attribute "munin"

if default['munin']['install_method'] == 'source'
  default['munin']['install_dir'] = "/opt/munin"
  default['munin']['basedir'] = "/etc/opt/munin"
  default['munin']['plugin_dir'] = "/opt/munin/lib/plugins"
  default['munin']['docroot'] = "/opt/munin/www/docs"
  default['munin']['dbdir'] = "/var/opt/munin"

  default['munin']['bin_dir'] = "#{default['munin']['install_dir']}/bin"
  default['munin']['sbin_dir'] = "#{default['munin']['install_dir']}/sbin"
  default['munin']['plugins'] = "#{default['munin']['basedir']}/plugins"
  default['munin']['tmpldir'] = "#{default['munin']['basedir']}/templates"
  default['munin']['static_dir'] = "#{default['munin']['static_dir']}/static"
  default['munin']['log_dir'] = "/opt/munin/log/munin"
end

default['munin']['source']['version'] = "2.0.17"
default['munin']['source']['force_recompile'] = false

default['munin']['source']['url'] = "http://downloads.sourceforge.net/project/munin/stable/#{node['munin']['source']['version']}/munin-#{node['munin']['source']['version']}.tar.gz"
default['munin']['source']['checksum'] = 'cfcc5bf3f8e568574ce897af7c17cc160def280e1ac63cd0796ca300ffef439e' # Sha256
