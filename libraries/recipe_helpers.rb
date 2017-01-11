
# These are intended to be public APIs and are deliberately injected into the
# Recipe DSL for use by end-users.  They should really get documented in
# the README.md

module SshknownhostsRecipeHelpers
  def ssh_known_hosts_partial_query(query)
    search(
      :node,
      query,
      filter_result: {
        'hostname'        => ['hostname'],
        'fqdn'            => ['fqdn'],
        'ipaddress'       => ['ipaddress'],
        'rsa' => %w(keys ssh host_rsa_public),
        'dsa' => %w(keys ssh host_dsa_public),
        'ecdsa' => %w(keys ssh host_ecdsa_public),
        'ed25519' => %w(keys ssh host_ed25519_public),
      }
    )
  end

  def ssh_known_hosts_from_node_search(query)
    hosts = ssh_known_hosts_partial_query(query)
    ssh_known_hosts_entries_from_node_data hosts
  end

  def ssh_known_hosts_from_data_bag!(data_bag)
    hosts = data_bag(data_bag).map do |item|
      data_bag_item(data_bag, item)
    end
    ssh_known_hosts_entries_from_node_data hosts
  end

  def ssh_known_hosts_from_data_bag(data_bag)
    ssh_known_hosts_from_data_bag!(data_bag)
  rescue # FIXME: exception types
    Chef::Log.info "Could not load data bag 'ssh_known_hosts'"
  end

  # injests from the same format as the partial search query above or
  # else a similarly formatted data bag or whatever
  def ssh_known_hosts_entries_from_node_data(hosts)
    hosts = hosts.flat_map do |host|
      key_types_from_node(host).map do |key_type|
        {
          'fqdn' => fqdn_from_node(host),
          'key' => host[key_type],
          'key_type' => key_type
        }
      end
    end

    ssh_known_hosts_entries hosts
  end

  # injests a array of hashes in the same format as the resource API
  def ssh_known_hosts_entries(hosts)
    # Loop over the hosts and add 'em
    hosts.each do |host|
      fqdn     = host['fqdn']
      key      = host['key']
      key_type = host['key_type']
      next if fqdn.nil?
      if key
        # The key was specified, so use it
        ssh_known_hosts_entry fqdn do
          key key
          key_type key_type unless key_type.nil?
        end
      else
        ssh_known_hosts_entry fqdn
      end
    end
  end

  private

  # takes node-ish object and finds a useful enough fqdn
  def fqdn_from_node(node)
    node['fqdn'] || node['ipaddress'] || node['hostname']
  end

  def key_types_from_node(data)
    present_keys = node['ssh_known_hosts']['key_types'].reject { |type| data[type].nil? }

    if node['ssh_known_hosts']['first_key_only']
      [present_keys.first]
    else
      present_keys
    end
  end
end

Chef::DSL::Recipe.send(:include, SshknownhostsRecipeHelpers)
