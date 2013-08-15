include_attribute "munin"

default['munin']['source']['install_dir'] = "/opt/munin"
default['munin']['source']['basedir'] = "/etc/opt/munin"
default['munin']['source']['plugin_dir'] = "/opt/munin/lib/plugins"
default['munin']['source']['docroot'] = "/opt/munin/www/docs"
default['munin']['source']['dbdir'] = "/var/opt/munin"

default['munin']['source']['bin_dir'] = "#{default['munin']['source']['install_dir']}/bin"
default['munin']['source']['sbin_dir'] = "#{default['munin']['source']['install_dir']}/sbin"
default['munin']['source']['plugins'] = "#{default['munin']['source']['basedir']}/plugins"
default['munin']['source']['tmpldir'] = "#{default['munin']['source']['basedir']}/templates"
default['munin']['source']['static_dir'] = "#{default['munin']['source']['static_dir']}/static"
default['munin']['source']['log_dir'] = "/opt/munin/log/munin"

default['munin']['source']['version'] = "2.0.17"
default['munin']['source']['force_recompile'] = false

default['munin']['source']['url'] = "http://downloads.sourceforge.net/project/munin/stable/#{node['munin']['source']['version']}/munin-#{node['munin']['source']['version']}.tar.gz"
default['munin']['source']['checksum'] = 'cfcc5bf3f8e568574ce897af7c17cc160def280e1ac63cd0796ca300ffef439e' # Sha256
