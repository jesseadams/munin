name              'munin'
maintainer        'Jesse R. Adams'
maintainer_email  'jesse@techno-geeks.org'
license           'Apache 2.0'
description       'Installs and configures munin'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '1.4.3'

depends 'apache2', '>= 1.7'
depends 'nginx',   '>= 1.8'

supports 'arch'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'freebsd'
supports 'redhat'
supports 'scientific'
supports 'ubuntu'

recipe 'munin', 'Empty, use one of the other recipes'
recipe 'munin::client', 'Instlls munin and configures a client by searching for the server, which should have a role named monitoring'
recipe 'munin::server', 'Installs munin and configures a server, node should have the role "monitoring" so clients can find it'
