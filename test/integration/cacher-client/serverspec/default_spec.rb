require 'spec_helper'

describe 'Known Hosts' do
  describe file('/etc/ssh/ssh_known_hosts') do
    its(:content) { should include "TEST_RSA_PUBLIC_KEY_HOST-1\n" }
    its(:content) { should include "TEST_ECDSA_PUBLIC_KEY_HOST-2\n" }
    its(:content) { should include "TEST_ED25519_PUBLIC_KEY_HOST-3\n" }
  end
end
