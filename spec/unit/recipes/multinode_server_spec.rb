require 'spec_helper'
require 'chefspec/server'

describe 'munin::server with clients' do
  let(:chef_run) do
    run = ChefSpec::Runner.new do |node|
      node.set['munin']['server_auth_method'] = 'htpasswd'
    end
    run.converge('recipe[munin::server]')
    return run
  end
  before do
    ChefSpec::Server.create_data_bag('users', {
      'seth' => { 'htpasswd' => 'abc123' },
      'nathen' => { 'htpasswd' => 'abc123' },
    })
    ChefSpec::Server.create_node('host1.example.com', {
      'run_list' => ['munin:xclient'],
      'name' => 'host0.example.com',
      'munin' => { server: {} },
      'fqdn' => 'host1.example.com',
      'ipaddress' => '127.0.0.2'
    })
    #ChefSpec::Server.create_node('host0.example.com', { run_list: ['munin:client'] })
  end

  context 'get multiple clients' do
    it 'should find host0' do
      expect(chef_run).to render_file('/etc/munin/munin.conf').with_content(/host1.example.com/)
    end
  end
end
