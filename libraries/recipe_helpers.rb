
module SshknownhostsRecipeHelpers
  def ssh_known_hosts_from_node_search(query)
    puts "ssh_knonw_hosts_from_node_search!: #{query}"
    hosts = search(
      :node,
      query,
      filter_result: {
        'hostname'        => ['hostname'],
        'fqdn'            => ['fqdn'],
        'ipaddress'       => ['ipaddress'],
        'rsa' => %w(keys ssh host_rsa_public),
        'dsa' => %w(keys ssh host_dsa_public),
        'ecdsa' => %w(keys ssh host_ecdsa_public),
        'ed25519' => %w(keys ssh host_ed25519_public)
      }
    ).map do |host|
      {
        'fqdn' => fqdn_from_node(host),
        'key'  => key_from_node(host),
        'key_type' => key_type_from_node(host)
      }
    end
    ssh_known_host_entries hosts
  end

  def ssh_known_hosts_from_data_bag!(data_bag)
    puts "ssh_knonw_hosts_from_data_bag!: #{data_bag}"
    hosts = data_bag(data_bag).map do |item|
      data_bag_item(data_bag, item)
    end.map do |entry|
      {
        'fqdn' => fqdn_from_host(entry),
        'key'  => key_from_node(entry),
        'key_type' => key_type_from_node(entry)
      }
    end
    ssh_known_host_entries hosts
  end

  def ssh_known_hosts_from_data_bag(data_bag)
    puts "ssh_knonw_hosts_from_data_bag: #{data_bag}"
    ssh_known_hosts_from_data_bag!(data_bag)
  rescue # FIXME: exception types
    Chef::Log.info "Could not load data bag 'ssh_known_hosts'"
  end

  def ssh_known_host_entries(hosts)
    puts "ssh_knonw_hosts_entries: #{hosts}"
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

  private

  # takes node-ish object and finds a useful enough fqdn
  def fqdn_from_node(node)
    node['fqdn'] || node['ipaddress'] || node['hostname']
  end

  def key_from_node(node)
    node['ed25519'] || node['ecdsa'] || node['rsa'] || node['dsa']
  end

  def key_type_from_node(node)
    %w{ed25519 ecdsa rsa dsa}.each do |type|
      return type if node[type]
    end
  end
end

Chef::DSL::Recipe.send(:include, SshknownhostsRecipeHelpers)
