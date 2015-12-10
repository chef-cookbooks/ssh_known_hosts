ssh_known_hosts Cookbook
========================

[![Build Status](https://travis-ci.org/chef-cookbooks/ssh_known_hosts.svg?branch=master)](http://travis-ci.org/chef-cookbooks/ssh_known_hosts)
[![Cookbook Version](https://img.shields.io/cookbook/v/ssh_known_hosts.svg)](https://supermarket.chef.io/cookbooks/ssh_known_hosts)

The Chef `ssh_known_hosts` cookbook exposes resource and default recipe for adding hosts and keys to the `/etc/ssh/ssh_known_hosts` file.

- The default recipe builds `/etc/ssh/ssh_known_hosts` based either on search indexes using `rsa,dsa` key types and ohai data **or**, when `['ssh_known_hosts']['use_data_bag_cache']` is `true`, on the contents of a data bag that is maintained by the `cacher` recipe running on a worker node.
- The cacher recipe builds and maintains a data bag based on search indexes using `rsa,dsa` key types and ohai data.
- The LWRP provides a way to add custom entries in your own recipes.

You can also optionally put other host keys in a data bag called "`ssh_known_hosts`". See below for details.


Requirements
------------
Should work on any operating system that supports `/etc/ssh/ssh_known_hosts`.

The Chef Software `partial_search` cookbook is required for the default recipe, as well as a Chef Server that supports partial search:

- Chef Software Hosted Chef
- Chef Software Private Chef
- Open Source Chef Server 11


Usage
-----
### LWRP

Use the LWRP `ssh_known_hosts_entry` to append an entry for the specified host in `/etc/ssh/ssh_known_hosts`. For example:

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

### Cacher

Use the `cacher` recipe on a single "worker" node somewhere in your cluster to maintain a data bag (`server_data/known_hosts` by default) containing all of your nodes host keys.  The advantage to this approach is that is much faster than running a search of all nodes, and substantially lightens the load on locally hosted Chef servers.  The drawback is that the data is slightly delayed (because the cacher worker must converge first).

To use the cacher, simply include the `ssh_known_hosts::cacher` cookbook in a wrapper cookbook or run list on a designated worker node.

#### Attributes

The following attributes are set on a per-platform basis, see the `attributes/default.rb`.

* `node['ssh_known_hosts']['file']` - Sets up the location of the ssh_known_hosts file for the system. 
  Defaults to '/etc/ssh/ssh_known_hosts'
* `node['ssh_known_hosts']['key_type']` - Determines which key type ssh-keyscan will use to determine the 
  host key, different systems will have different available key types, check your manpage for available 
  key types for ssh-keyscan. Defaults to 'rsa,dsa'
* `node['ssh_known_hosts']['use_data_bag_cache']` - Use the data bag maintained by the cacher server to build `/etc/ssh/ssh_known_hosts` instead of a direct search (requires that a node be set up to run the cacher recipe regularly).
* `node['ssh_known_hosts']['cacher']['data_bag']`/`node['ssh_known_hosts']['cacher']['data_bag_item']` - Data bag where cacher recipe should store its keys.
* `node['ssh_known_hosts']['multi_environment']` - Array of chef environments to search if not empty and
  cacher is disabled. Defaults to '[]' which means search all environments
* `node['ssh_known_hosts']['use_search']` - Determines if search is used at all when cacher is disabled.
  Defaults to true

#### LWRP Attributes

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Example</th>
      <th>Default</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>host</td>
      <td>the host to add</td>
      <td><tt>github.com</tt></td>
      <td></td>
    </tr>
    <tr>
      <td>key</td>
      <td>(optional) provide your own key</td>
      <td><tt>ssh-rsa ...</tt></td>
      <td><tt>ssh-keyscan -H #{host}</tt></td>
    </tr>
    <tr>
      <td>port</td>
      <td>(optional) the server port that ssh-keyscan will use to gather the public key</td>
      <td><tt>2222</tt></td>
      <td><tt>22</tt></td>
    </tr>
  </tbody>
</table>

- - -

### Default Recipe

Searches the Chef Server for all hosts that have SSH host keys using `rsa,dsa` key types and generates an `/etc/ssh/ssh_known_hosts`.

#### Adding custom host keys

There are two ways to add custom host keys. You can either use the provided LWRP (see above), or by creating a data bag called "`ssh_known_hosts`" and adding an item for each host:

```javascript
{
  "id": "github",
  "fqdn": "github.com",
  "rsa": "github-rsa-host-key"
}
```

There are additional optional values you may use in the data bag:

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Example</th>
      <th>Default</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>id</td>
      <td>a unique id for this data bag entry</td>
      <td><tt>github</tt></td>
      <td></td>
    </tr>
    <tr>
      <td>fqdn</td>
      <td>the fqdn of the host</td>
      <td><tt>github.com</tt></td>
      <td></td>
    </tr>
    <tr>
      <td>rsa</td>
      <td>the rsa key for this server</td>
      <td><tt>ssh-rsa AAAAB3...</tt></td>
      <td></td>
    </tr>
    <tr>
      <td>ipaddress</td>
      <td>the ipaddress of the node (if fqdn is missing)</td>
      <td><tt>1.1.1.1</tt></td>
      <td></td>
    </tr>
    <tr>
      <td>hostname</td>
      <td>local hostname of the server (if not a fqdn)</td>
      <td><tt>myserver.local</tt></td>
      <td></td>
    </tr>
    <tr>
      <td>dsa</td>
      <td>the dsa key for this server</td>
      <td><tt>ssh-dsa ABAAC3...</tt></td>
      <td></td>
    </tr>
  </tbody>
</table>

###ChefSpec matchers

A custom matcher is available for you to use in recipe tests.

``` 
describe 'my_cookbook::my_recipe' do
	let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
	it { expect(chef_run).to append_to_ssh_known_hosts 'github.com' }
end
```


License & Authors
-----------------

**Author:** Cookbook Engineering Team (<cookbooks@chef.io>)

**Copyright:** 2008-2015, Chef Software, Inc.

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

