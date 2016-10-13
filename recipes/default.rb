#
# Cookbook Name:: ssh_known_hosts
# Recipe:: default
#
# Author:: Scott M. Likens (<scott@likens.us>)
# Author:: Joshua Timberman (<joshua@chef.io>)
# Author:: Seth Vargo (<sethvargo@gmail.com>)
#
# Copyright 2009, Adapp, Inc.
# Copyright 2011-2016, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
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

  pp data_bag_item(
    node['ssh_known_hosts']['cacher']['data_bag'],
    node['ssh_known_hosts']['cacher']['data_bag_item']
  )

  hosts = data_bag_item(
    node['ssh_known_hosts']['cacher']['data_bag'],
    node['ssh_known_hosts']['cacher']['data_bag_item']
  )['keys']
  Chef::Log.info "hosts data bag: #{hosts.inspect}"
  ssh_known_hosts_entries hosts
else
  # FIXME: should change the syntax here, but chef-zero's search parser is broken
  ssh_known_hosts_from_node_search("keys_ssh:* NOT name:#{node.name}")
end

ssh_known_hosts_from_data_bag('ssh_known_hosts')
