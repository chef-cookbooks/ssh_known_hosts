require 'spec_helper'

describe 'Known Hosts' do
  describe file('/etc/ssh/ssh_known_hosts') do
    its(:content) { should include 'TEST_RSA_PUBLIC_KEY_HOST-1' }
    its(:content) { should include 'TEST_RSA_PUBLIC_KEY_HOST-2' }
    its(:content) { should include 'TEST_RSA_PUBLIC_KEY_HOST-3' }
  end
end
