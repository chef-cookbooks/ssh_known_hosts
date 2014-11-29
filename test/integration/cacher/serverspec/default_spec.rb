require 'spec_helper'

describe 'Known Hosts' do
  # This here is some serious voodoo but it SHOULD work and provide a good
  # test.
  describe file('/tmp/kitchen/data_bags/server_data/known_hosts.json') do
    its(:content) { should include 'TEST_RSA_PUBLIC_KEY_HOST-1' }
    its(:content) { should include 'TEST_RSA_PUBLIC_KEY_HOST-2' }
    its(:content) { should include 'TEST_RSA_PUBLIC_KEY_HOST-3' }
  end
end
