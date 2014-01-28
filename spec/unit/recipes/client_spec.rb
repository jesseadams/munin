require 'spec_helper'

describe 'munin::client' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'installs the munin-node package' do
    expect(chef_run).to install_package('munin-node')
  end

  it 'writes the munin-node.conf' do
    expect(chef_run).to create_template('/etc/munin/munin-node.conf').with(
      source: 'munin-node.conf.erb',
      mode: '0644'
    )

    template = chef_run.template('/etc/munin/munin-node.conf')
    expect(template).to notify('service[munin-node]').to(:restart)
  end

  it 'starts and enables the service' do
    expect(chef_run).to start_service('munin-node')
    expect(chef_run).to enable_service('munin-node')
  end
end
