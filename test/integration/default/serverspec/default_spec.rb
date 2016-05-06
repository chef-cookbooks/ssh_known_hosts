require 'spec_helper'

describe 'Known Hosts' do
  # This here is some serious voodoo but it SHOULD work and provide a good
  # test.
  describe file('/etc/ssh/ssh_known_hosts') do
    its(:content) { should include "ssh-rsa TEST_RSA_PUBLIC_KEY_HOST-1\n" }
    its(:content) { should include "ecdsa-sha2-nistp256 TEST_ECDSA_PUBLIC_KEY_HOST-2\n" }
    its(:content) { should include "ssh-ed25519 TEST_ED25519_PUBLIC_KEY_HOST-3\n" }
  end
end
