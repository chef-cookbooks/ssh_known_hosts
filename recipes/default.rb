#
# Cookbook Name:: ssh_known_hosts
# Recipe:: default
#
# Author:: Scott M. Likens (<scott@likens.us>)
# Author:: Joshua Timberman (<joshua@chef.io>)
# Author:: Seth Vargo (<sethvargo@gmail.com>)
#
# Copyright 2009, Adapp, Inc.
# Copyright 2011-2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if node['ssh_known_hosts']['use_data_bag_cache']
  # Load hosts from the ssh known hosts cacher (if the data bag exists)
  unless Chef::DataBag.list.key?(node['ssh_known_hosts']['cacher']['data_bag'])
    raise 'use_data_bag_cache is set but the configured data bag was not found'
  end

  hosts = data_bag_item(
    node['ssh_known_hosts']['cacher']['data_bag'],
    node['ssh_known_hosts']['cacher']['data_bag_item']
  )['keys']
  Chef::Log.info "hosts data bag: #{hosts.inspect}"
else
  hosts = SshknownhostsCookbook::KeysSearch.hosts_keys("keys_ssh:* NOT name:#{node.name}")
end

# Add the data from the data_bag to the list of nodes.
# We need to rescue in case the data_bag doesn't exist.
if Chef::DataBag.list.key?('ssh_known_hosts')
  begin
    hosts += data_bag('ssh_known_hosts').collect do |item|
      entry = data_bag_item('ssh_known_hosts', item)
      {
        'fqdn' => entry['fqdn'] || entry['ipaddress'] || entry['hostname'],
        'key'  => entry['ed25519'] || entry['ecdsa'] || entry['rsa'] || entry['dsa']
      }
    end
  rescue
    Chef::Log.info "Could not load data bag 'ssh_known_hosts'"
  end
end

# Loop over the hosts and add 'em
hosts.each do |host|
  if host['key']
    # The key was specified, so use it
    ssh_known_hosts_entry host['fqdn'] do
      key host['key']
      key_type host['key_type']
    end
  else
    # No key specified, so have known_host perform a DNS lookup
    ssh_known_hosts_entry host['fqdn'] unless host['fqdn'].nil?
  end
end
