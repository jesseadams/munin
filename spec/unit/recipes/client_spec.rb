require 'spec_helper'

describe 'munin::client' do
  let(:chef_run) { ChefSpec::ChefRunner.new.converge(described_recipe) }

  it 'installs the munin-node package' do
    expect(chef_run).to install_package('munin-node')
  end

  it 'writes the munin-node.conf' do
    template = chef_run.template('/etc/munin/munin-node.conf')
    expect(template).to be
    expect(template.source).to eq('munin-node.conf.erb')
    expect(template.mode).to eq('0644')
    expect(template).to notify('service[munin-node]', :restart)
  end

  it 'starts and enables the service' do
    expect(chef_run).to start_service('munin-node')
    expect(chef_run).to set_service_to_start_on_boot('munin-node')
  end
end
