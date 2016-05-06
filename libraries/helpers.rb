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
end
