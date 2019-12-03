require 'spec_helper'

describe 'Known Hosts' do
  # This here is some serious voodoo but it SHOULD work and provide a good
  # test.
  describe file('/etc/ssh/ssh_known_hosts') do
    its(:content) { should include "host-1.vagrantup.com,10.0.2.16,host-1 ssh-rsa TEST_RSA_PUBLIC_KEY_HOST-1\n" }
    its(:content) { should include "host-2.vagrantup.com,10.0.2.17 ecdsa-sha2-nistp256 TEST_ECDSA_PUBLIC_KEY_HOST-2\n" }
    its(:content) { should include "host-3.vagrantup.com,host-3 ssh-ed25519 TEST_ED25519_PUBLIC_KEY_HOST-3\n" }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
  end
end
