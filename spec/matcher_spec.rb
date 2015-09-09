require 'spec_helper'

describe 'ssh_known_hosts_test::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.converge(described_recipe)
  end

  it { expect(chef_run).to append_to_ssh_known_hosts 'github.com' }
end
