# Gather a list of all nodes, warning if using Chef Solo
if Chef::Config[:solo]
  fail 'ssh_known_hosts::cacher requires Chef search - Chef Solo does ' \
    'not support search!'
else
  all_host_keys = partial_search(
    :node, 'keys_ssh:*',
    :keys => {
      'hostname'        => [ 'hostname' ],
      'fqdn'            => [ 'fqdn' ],
      'ipaddress'       => [ 'ipaddress' ],
      'host_rsa_public' => [ 'keys', 'ssh', 'host_rsa_public' ],
      'host_dsa_public' => [ 'keys', 'ssh', 'host_dsa_public' ]
    }
  ).collect do |host|
    {
      'fqdn' => host['fqdn'] || host['ipaddress'] || host['hostname'],
      'key' => host['host_rsa_public'] || host['host_dsa_public']
    }
  end
end

unless Chef::DataBag.list.key?(node['ssh_known_hosts']['cacher']['data_bag'])
  new_databag = Chef::DataBag.new
  new_databag.name(node['ssh_known_hosts']['cacher']['data_bag'])
  new_databag.save
end

host_key_db_item = Chef::DataBagItem.new
host_key_db_item.data_bag(node['ssh_known_hosts']['cacher']['data_bag'])
host_key_db_item.raw_data = {
  "id" => node['ssh_known_hosts']['cacher']['data_bag_item'],
  "keys" => all_host_keys
}

host_key_db_item.save
