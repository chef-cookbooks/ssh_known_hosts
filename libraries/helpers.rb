module SshknownhostsCookbook
  def self.key_from(host)
    key_types = {
      'ssh-ed25519' => host['host_ed25519_public'],
      'ecdsa-sha2-nistp256' => host['host_ecdsa_public'],
      'ssh-rsa' => host['host_rsa_public'],
      'ssh-dsa' => host['host_dsa_public']
    }
    key_types.each do |cipher, key|
      return OpenStruct.new(cipher: cipher, key: key) if key
    end
  end

  module KeysSearch
    extend Chef::DSL::DataQuery

    def self.hosts_keys(pattern)
      search(
        :node, pattern,
        filter_result: {
          'hostname'        => ['hostname'],
          'fqdn'            => ['fqdn'],
          'ipaddress'       => ['ipaddress'],
          'host_rsa_public' => %w(keys ssh host_rsa_public),
          'host_dsa_public' => %w(keys ssh host_dsa_public),
          'host_ecdsa_public' => %w(keys ssh host_ecdsa_public),
          'host_ed25519_public' => %w(keys ssh host_ed25519_public)
        }
      ).collect do |host|
        {
          'fqdn' => host['fqdn'] || host['ipaddress'] || host['hostname'],
          'key' => SshknownhostsCookbook.key_from(host).key,
          'key_type' => SshknownhostsCookbook.key_from(host).cipher
        }
      end
    end
  end
end
