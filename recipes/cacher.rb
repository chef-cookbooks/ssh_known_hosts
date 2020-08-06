all_host_keys = ssh_known_hosts_partial_query('keys:*')
Chef::Log.debug("Partial search got: #{all_host_keys.inspect}")

new_data_bag_content = {
  'id' => node['ssh_known_hosts']['cacher']['data_bag_item'],
  'keys' => all_host_keys,
}

Chef::Log.debug("New data bag content: #{new_data_bag_content.inspect}")

if Chef::DataBag.list.key?(node['ssh_known_hosts']['cacher']['data_bag'])
  # Check to see if there are actually any changes to be made (so we don't save
  # data bags unnecessarily)
  existing_data_bag_content = data_bag_item(
    node['ssh_known_hosts']['cacher']['data_bag'],
    node['ssh_known_hosts']['cacher']['data_bag_item']
  ).raw_data
  Chef::Log.debug("Existing data bag content: #{existing_data_bag_content.inspect}")
else
  Chef::Log.debug('Data bag ' \
    "\"#{node['ssh_known_hosts']['cacher']['data_bag']}\" not found.  " \
    'Creating.')
  new_databag = Chef::DataBag.new
  new_databag.name(node['ssh_known_hosts']['cacher']['data_bag'])
  new_databag.save
end

unless (defined? existing_data_bag_content) &&
       new_data_bag_content == existing_data_bag_content

  Chef::Log.debug('Data bag contents differ.  Saving updates.')

  host_key_db_item = Chef::DataBagItem.new
  host_key_db_item.data_bag(node['ssh_known_hosts']['cacher']['data_bag'])
  host_key_db_item.raw_data = new_data_bag_content

  host_key_db_item.save
end
