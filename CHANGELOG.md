ssh_known_hosts Cookbook CHANGELOG
==================================
This file is used to list changes made in each version of the ssh_known_hosts cookbook.


v1.1.0
------

Added port and type parameters to `ssh_known_hosts_entry` LWRP

v1.0.2
------
### Bug
- **[COOK-3113](https://tickets.opscode.com/browse/COOK-3113)** - Use empty string when result is `nil`

v1.0.0
------
This is a major release because it requires a server that supports the partial search feature.

- Opscode Hosted Chef
- Opscode Private Chef
- Open Source Chef 11

### Improvement

- [COOK-830]: uses an inordinate amount of RAM when running exception handlers

v0.7.4
------
- [COOK-2440] - `ssh_known_hosts` fails to use data bag entries, doesn't grab items

v0.7.2
------
- [COOK-2364] - Wrong LWRP name used in recipe

v0.7.0
------
- [COOK-2320] - Merge `known_host` LWRP into `ssh_known_hosts`

v0.6.0
------
- [COOK-2268] - Allow to run with chef-solo

v0.5.0
------
- [COOK-1077] - allow adding arbitrary host keys from a data bag

v0.4.0
------
- COOK-493: include fqdn
- COOK-721: corrected permissions
