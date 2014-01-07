require 'spec_helper'

describe 'munin::client' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'installs the munin-node package' do
    expect(chef_run).to install_package('munin-node')
  end

  it 'writes the munin-node.conf' do
    template = chef_run.template('/etc/munin/munin-node.conf')
    expect(template).to be
    expect(template.source).to eq('munin-node.conf.erb')
    expect(template.mode).to eq('0644')
    notify('service[munin-node]').to(:restart)
  end

  it 'starts and enables the service' do
    notify('service[munin-node]').to(:start)
    expect(chef_run).to enable_service('munin-node')
  end
end
