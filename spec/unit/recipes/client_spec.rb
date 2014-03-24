require 'spec_helper'

describe 'munin::client' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'installs the munin-node package' do
    expect(chef_run).to install_package('munin-node')
  end

  describe 'the munin-node.conf' do
    let(:conf_path) { '/etc/munin/munin-node.conf' }

    it 'is based on the template' do
      expect(chef_run)
        .to create_template(conf_path)
        .with(source: 'munin-node.conf.erb')
    end

    it 'is mode 0644' do
      expect(chef_run)
        .to create_template(conf_path)
        .with(mode: '0644')
    end

    describe 'template' do
      it 'notifies munin-node to restart' do
        template = chef_run.template(conf_path)
        expect(template)
          .to notify('service[munin-node]')
          .to(:restart)
      end

      context 'with a list of server names' do
        let(:chef_run) do
          ChefSpec::Runner.new do |node|
            node.normal['munin']['server_list'] = fake_dns.keys
          end.converge(described_recipe)
        end

        before do
          fake_dns.each_pair do |host, ip|
            allow(IPSocket)
              .to receive(:getaddress)
              .with(host)
              .and_return(ip)
          end
        end

        let(:fake_dns) do
          {
            'server1.example.com' => '127.0.1.1',
            'server2.example.com' => '127.0.1.2'
          }
        end

        it 'always allows access to localhost' do
          expect(chef_run)
            .to render_file(conf_path)
            .with_content('allow ^127\.0\.0\.1$')
        end

        it 'allows access to the servers' do
          fake_dns.values.each do |ip|
            expect(chef_run)
              .to render_file(conf_path)
              .with_content("allow ^#{ip.gsub('.', '\\.')}$")
          end
        end

        it 'looks up the ip addresses' do
          fake_dns.keys.each do |host|
            expect(IPSocket)
              .to receive(:getaddress)
              .with(host)
          end

          chef_run
        end
      end

      context 'with chef-solo' do
        it 'allows itself access' do
          expect(chef_run)
            .to render_file(conf_path)
            .with_content('allow ^127\.0\.0\.1$')
        end
      end

      # TODO: Test the non-chef-solo path
    end
  end

  it 'starts and enables the service' do
    expect(chef_run).to start_service('munin-node')
    expect(chef_run).to enable_service('munin-node')
  end
end
