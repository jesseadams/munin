require 'spec_helper'
require 'chefspec/server'

describe 'munin::server' do

  context 'with clients in the same environment' do

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
      host0 = stub_node('host0', platform:'debian', version:'7.1', ohai:{'fqdn'=> 'host0.example.com', 'ipaddress'=> '192.168.0.10', 'munin'=> {}, recipes:['recipe[munin::client]']})
      ChefSpec::Server.create_node('host0.example.com', host0)
      host1 = stub_node('host1', platform:'debian', version:'7.1', ohai:{'fqdn'=> 'host1.example.com', 'ipaddress'=> '192.168.0.11', 'munin'=> {}, recipes:['recipe[munin::client]']})
      ChefSpec::Server.create_node('host1.example.com', host1)
    end

    context 'get multiple clients' do

      it 'should find host0' do
        expect(chef_run).to render_file('/etc/munin/munin.conf').with_content(/host0.example.com/)
        expect(chef_run).to render_file('/etc/munin/munin.conf').with_content(/192\.168\.0\.10/)
      end

      it 'should find host1' do
        expect(chef_run).to render_file('/etc/munin/munin.conf').with_content(/host1.example.com/)
        expect(chef_run).to render_file('/etc/munin/munin.conf').with_content(/192\.168\.0\.11/)
      end

    end

  end

  context 'with clients in a different environment' do

    before do
      ChefSpec::Server.create_data_bag('users', {
        'seth' => { 'htpasswd' => 'abc123' },
        'nathen' => { 'htpasswd' => 'abc123' },
      })
      ChefSpec::Server.create_environment('offsite')
      host0 = stub_node('host0', platform:'debian', version:'7.1', ohai:{'fqdn'=> 'host0.example.com', 'ipaddress'=> '192.168.0.10', 'munin'=> {}, recipes:['recipe[munin::client]'], chef_environment:'offsite'})
      ChefSpec::Server.create_node('host0.example.com', host0)
      host1 = stub_node('host1', platform:'debian', version:'7.1', ohai:{'fqdn'=> 'host1.example.com', 'ipaddress'=> '192.168.0.11', 'munin'=> {}, recipes:['recipe[munin::client]'], chef_environment:'offsite'})
      ChefSpec::Server.create_node('host1.example.com', host1)
    end

    context 'single environment server' do
      let(:chef_run) do
        run = ChefSpec::Runner.new do |node|
          node.set['munin']['server_auth_method'] = 'htpasswd'
        end
        run.converge('recipe[munin::server]')
        return run
      end

      it 'should not find itself' do
        expect(chef_run).to render_file('/etc/munin/munin.conf')
        expect(chef_run).not_to render_file('/etc/munin/munin.conf').with_content(/\[chefspec.local\]/)
      end

      it 'should not find the others' do
        expect(chef_run).not_to create_file('/etc/munin/munin.conf').with_content(/\[host0.example.com\]/)
      end
    end

    context 'multi environment server' do
      let(:chef_run) do
        run = ChefSpec::Runner.new do |node|
          node.set['munin']['server_auth_method'] = 'htpasswd'
          node.set['munin']['multi_environment_monitoring'] = 'true'
        end
        run.converge('recipe[munin::server]')
        return run
      end

      it 'should not find itself' do
        expect(chef_run).to create_file('/etc/munin/munin.conf')
        expect(chef_run).not_to render_file('/etc/munin/munin.conf').with_content(/\[chefspec.local\]/)
      end

      it 'should find the others' do
        expect(chef_run).to create_file('/etc/munin/munin.conf')
        expect(chef_run).to create_file('/etc/munin/munin.conf').with_content(/\[host0.example.com\]/)
      end
    end
  end
end
