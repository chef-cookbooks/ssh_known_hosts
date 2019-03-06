# ssh_known_hosts Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/ssh_known_hosts.svg?branch=master)](http://travis-ci.org/chef-cookbooks/ssh_known_hosts) [![Cookbook Version](https://img.shields.io/cookbook/v/ssh_known_hosts.svg)](https://supermarket.chef.io/cookbooks/ssh_known_hosts)

The Chef `ssh_known_hosts` cookbook exposes a resource as well as a recipe for adding hosts and keys to the `/etc/ssh/ssh_known_hosts` file, the global file for public keys on known hosts.

- The default recipe builds `/etc/ssh/ssh_known_hosts` based either on search indexes using `rsa,dsa` key types and ohai data **or**, when `['ssh_known_hosts']['use_data_bag_cache']` is `true`, on the contents of a data bag that is maintained by the `cacher` recipe running on a worker node.
- The cacher recipe builds and maintains a data bag based on search indexes using `rsa,dsa` key types and ohai data.
- The resource provides a way to add custom entries in your own recipes.

You can also optionally put other host keys in a data bag called "`ssh_known_hosts`". See below for details.

NOTE: The `ssh_known_hosts_entry` resource is now built into Chef 14.4+. When Chef 15.4 is released (April 2019) this resource will be removed from this cookbook as all users should be on Chef 14.4+.

## Requirements

### Platforms

- Any operating system that supports `/etc/ssh/ssh_known_hosts`.

### Chef

- 12.11+

## Resource

### ssh_known_hosts_entry

Use the `ssh_known_hosts_entry` resource to append an entry for the specified host in `/etc/ssh/ssh_known_hosts`. For example:

#### Actions

- `:create` - Create an entry (default)
- `:flush` - Immediately flush the entries to the config file (see example below)

#### Properties

Property      | Description                                                                                                      | Example                          | Default
------------- | ---------------------------------------------------------------------------------------------------------------- | -------------------------------- | --------------------------
host          | The host to add to the known hosts file.                                                                         | 'github.com'                     | the resource name
key           | (optional) The key for the host. If not provided this will be automatically determined.                          | ssh-rsa ...                      | ssh-keyscan -H #{host}
key_type      | (optional) The type of key to store.                                                                             | 'dsa'                            | rsa
port          | (optional) The server port that ssh-keyscan will use to gather the public key.                                   | 2222                             | 22
timeout       | (optional) The timeout in seconds for ssh-keyscan.                                                               | 90                               | 30
mode          | (optional) The file mode for the ssh_known_hosts file.                                                           | '0644'                           | '0644'
owner         | (optional) The file owner for the ssh_known_hosts file.                                                          | 'root'                           | 'root'
group         | (optional) The file group for the ssh_known_hosts file.                                                          | 'wheel'                          | 'root'
hash_entries  | (optional) Hash the hostname and addresses in the ssh_known_hosts file for privacy.                              | true                             | false
file_location | (optional) The location of the ssh known hosts file. Change this to set a known host file for a particular user. | '/Users/tsmith/.ssh/known_hosts' | '/etc/ssh/ssh_known_hosts'

#### Examples

Add a single entry for github.com:

```ruby
ssh_known_hosts_entry 'github.com'
```

This will append an entry in `/etc/ssh/ssh_known_hosts` like this:

```text
# github.com SSH-2.0-OpenSSH_5.5p1 Debian-6+squeeze1+github8
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
```

You can optionally specify your own key, if you don't want to use `ssh-keyscan`:

```ruby
ssh_known_hosts_entry 'github.com' do
  key 'node.example.com ssh-rsa ...'
end
```

The latest design of this cookbook only writes the `/etc/ssh/ssh_known_hosts` file at the very end of the chef-client run. In order to force it to update the template earlier use the `:flush` action:

```ruby
ssh_known_hosts_entry "doesn't matter" do
  action :flush
end
```

The user is responsible for only calling the flush action at the end of constructing their entries. Calling it first is illegal, calling it in the middle will result with partial content written to disk and chef-client will always show at least two resources being updated (and flapping).

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
- `node['ssh_known_hosts']['cacher']['node_search_query']` - Additional query string to apply to the cacher search (useful in large environments)
- `node['ssh_known_hosts']['node_search_query']` - Additional query string to apply to the search

## License & Authors

**Author:** Cookbook Engineering Team ([cookbooks@chef.io](mailto:cookbooks@chef.io))

**Copyright:** 2008-2018, Chef Software, Inc.

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
