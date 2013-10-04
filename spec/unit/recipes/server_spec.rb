require 'spec_helper'

describe 'munin::server' do
  let(:chef_run) { ChefSpec::ChefRunner.new.converge(described_recipe) }

  before do
    Chef::Recipe.any_instance.stub(:data_bag).with('users').and_return(%w[seth nathen])

    Chef::Recipe.any_instance.stub(:data_bag_item).with('users', 'seth').and_return(
      Mash.new(id: 'seth', htpasswd: 'abc123')
    )
    Chef::Recipe.any_instance.stub(:data_bag_item).with('users', 'nathen').and_return(
      Mash.new(id: 'nathen', htpasswd: 'abc123')
    )
  end

  context 'when the web server is apache' do
    it 'includes the `server_apache`recipe`' do
      # expect(chef_run).to include_recipe('munin::server_apache')
      pending 'This recipe is pretty much untestable'
    end
  end

  context 'when the web server is nginx' do
    it 'includes the `server_nginx`recipe`' do
      # expect(chef_run).to include_recipe('munin::server_nginx')
      pending 'This recipe is pretty much untestable'
    end
  end

  context 'when the web server is bacon' do
    it 'raises an exception' do
      # expect { chef_run }.to raise_error
      pending 'This recipe is pretty much untestable'
    end
  end
end
