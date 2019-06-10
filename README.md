# ssh_known_hosts Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/ssh_known_hosts.svg?branch=master)](http://travis-ci.org/chef-cookbooks/ssh_known_hosts) [![Cookbook Version](https://img.shields.io/cookbook/v/ssh_known_hosts.svg)](https://supermarket.chef.io/cookbooks/ssh_known_hosts)

- The default recipe builds `/etc/ssh/ssh_known_hosts` based either on search indexes using `rsa,dsa` key types and ohai data **or**, when `['ssh_known_hosts']['use_data_bag_cache']` is `true`, on the contents of a data bag that is maintained by the `cacher` recipe running on a worker node.
- The cacher recipe builds and maintains a data bag based on search indexes using `rsa,dsa` key types and ohai data.

You can also optionally put other host keys in a data bag called "`ssh_known_hosts`". See below for details.

WARNING: The `ssh_known_hosts_entry` resource is now built into Chef 14.4+ and no longer ships in this cookbook.

## Requirements

### Platforms

- Any operating system that supports `/etc/ssh/ssh_known_hosts`.

### Chef

- 14.4+

## Recipes

### Cacher

Use the `cacher` recipe on a single "worker" node somewhere in your cluster to maintain a data bag (`server_data/known_hosts` by default) containing all of your nodes host keys. The advantage to this approach is that is much faster than running a search of all nodes, and substantially lightens the load on locally hosted Chef servers. The drawback is that the data is slightly delayed (because the cacher worker must converge first).

To use the cacher, simply include the `ssh_known_hosts::cacher` cookbook in a wrapper cookbook or run list on a designated worker node.

### Default Recipe

Searches the Chef Server for all hosts that have SSH host keys using `rsa,dsa` key types and generates an `/etc/ssh/ssh_known_hosts`.

#### Adding custom host keys

There are two ways to add custom host keys. You can either use the resource (see above), or by creating a data bag called "`ssh_known_hosts`" and adding an item for each host:

```javascript
{
  "id": "github",
  "fqdn": "github.com",
  "rsa": "github-rsa-host-key"
}
```

There are additional optional values you may use in the data bag:

Attribute | Description                                         | Example
--------- | --------------------------------------------------- | -----------------
id        | a unique id for this data bag entry                 | github
fqdn      | the fqdn of the host                                | github.com
rsa       | the rsa key for this server                         | ssh-rsa AAAAB3...
ipaddress | the ipaddress of the node (if fqdn is not supplied) | 1.1.1.1
hostname  | local hostname of the server (if not a fqdn)        | myserver.local
dsa       | the dsa key for this server                         | ssh-dsa ABAAC3...

## Attributes

The following attributes are set on a per-platform basis, see the `attributes/default.rb`.

- `node['ssh_known_hosts']['file']` - Sets up the location of the ssh_known_hosts file for the system. Defaults to '/etc/ssh/ssh_known_hosts'
- `node['ssh_known_hosts']['key_type']` - Determines which key type ssh-keyscan will use to determine the host key, different systems will have different available key types, check your manpage for available key types for ssh-keyscan. Defaults to 'rsa,dsa'
- `node['ssh_known_hosts']['use_data_bag_cache']` - Use the data bag maintained by the cacher server to build `/etc/ssh/ssh_known_hosts` instead of a direct search (requires that a node be set up to run the cacher recipe regularly).
- `node['ssh_known_hosts']['cacher']['data_bag']`/`node['ssh_known_hosts']['cacher']['data_bag_item']` - Data bag where cacher recipe should store its keys.
- `node['ssh_known_hosts']['node_search_query']` - Additional query string to apply to the search

## License & Authors

**Author:** Cookbook Engineering Team ([cookbooks@chef.io](mailto:cookbooks@chef.io))

**Copyright:** 2008-2019, Chef Software, Inc.

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
