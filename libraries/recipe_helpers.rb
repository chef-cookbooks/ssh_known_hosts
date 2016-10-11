
module SshknownhostsRecipeHelpers
  def ssh_known_host_entries(hosts)
    # Loop over the hosts and add 'em
    hosts.each do |host|
      if host['fqdn'].nil?
        # No key specified, so have known_host perform a DNS lookup
        ssh_known_hosts_entry host['fqdn']
      else
        next unless host['key']
        # The key was specified, so use it
        ssh_known_hosts_entry host['fqdn'] do
          key host['key']
          key_type host['key_type']
        end
      end
    end
  end
end

Chef::DSL::Recipe.send(:include, SshknownhostsRecipeHelpers)
