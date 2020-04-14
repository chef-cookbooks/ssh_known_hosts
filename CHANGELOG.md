# ssh_known_hosts CHANGELOG

This file is used to list changes made in each version of the ssh_known_hosts cookbook.

## Unreleased

- resolved cookstyle error: libraries/recipe_helpers.rb:2:1 refactor: `ChefStyle/CommentFormat`

## 7.0.0 (2019-06-10)

### Breaking Changes
  - Requires Chef 14.4 or later
  - Removes the ::deprecated recipe that was undocumented, but included for long back backwards compatibility
  - Removes the resource which is now included in Chef 14.4 or later

## 6.2.0 (2018-09-10)

- Add all known keys to the known hosts by default, but add option to keep old behaviour.
- Make names of resources with different key types unique

## 6.1.3 (2018-09-04)

- Allow additional query params in Chef search
- The `ssh_known_hosts_entry` resource is now built into Chef 14.4+. When Chef 15.4 is released (April 2019) this resource will be removed from this cookbook as all users should be on Chef 14.4+.

## 6.1.2 (2018-04-27)

- Use root_group for the group ownership to support macOS and BSD

## 6.1.1 (2018-04-27)

- Document a few missing properties in the resource

## 6.1.0 (2018-04-16)

- Use delayed_action instead of a log resource with notification. This makes the resource runs a bit cleaner as you won't see a log resource converging as well
- Add a new property `file_location` for controlling where the ssh config is. This defaults to the previously set value from the node attribute, but can be set on individual resources. This also lets you set the path to a particular user's ssh known host file if you want to modify that.
- By default only set key type of RSA not RSA and DSA. You can modify this behavior by setting the key_type property. Previously we used the node level attribute, but this didn't allow you to change the behavior on individual resources

## 6.0.0 (2018-04-16)

- add a :flush action to ssh_known_hosts_entry which immediatly writes the file to disk. See the readme for an example of how to use this
- Remove action_class.class_eval and just use action_class instead
- Increase the required Chef release to 12.11 for some of the accumulator functionality we use now
- Improve testing
- Improve the docs for the resource

## 5.2.1 (2017-05-30)

- Resolve foodcritic warnings

## 5.2.0 (2017-05-30)

- Update apache2 license string
- Add supports metadata
- Remove class_eval usage and require Chef 12.7+

## 5.1.0 (2017-03-14)

- add support for hashed entries when using keyscan
- Test with Local Delivery instead of Rake
- add a "deprecated" recipe for back-compat-ish behavior

## 5.0.0 (2017-02-23)

- Require Chef 12.5+ and remove compat_resource dependency

## 4.1.1 (2017-01-06)

- Do not write port number if it is 22

## 4.1.0 (2016-12-29)

- Convert entry LWRP to a custom_resource with a delayed accumulator pattern
- Resolve sort ordering issues
- Fix for non-port-22 issues
- Add helper correctly in the recipe DSL

## 4.0.0 (2016-09-07)

- Require chef 12+
- Testing updates
- Remove chef 10 compatibility code

## v3.1.0 (2016-07-18)

- [#59] adds mode, owner, group attributes to the entry resource

## v3.0.1 (2016-07-15)

- [#58] Fix issues brought in with v3.0.0 with ssh-keyscan
- [#58] Add timeout parameter to entry resource associated with ssh-keyscan
- [#58] Cleaned up some extraneous old chef-solo code

## v3.0.0 (2016-07-14)

- [#55] Remove deprecated cookbook dependency on partial_search making cookbook Chef 12+ only

## v2.1.0 (2016-07-13)

- [#51] Add support for ECDSA and ED25519 keys josacar
- [#42] Check for nil FQDN realloc

## v2.0.0 (2014-12-02)

- [#36] Fix the way keys are rendered
- [#22] Update to README
- [#32] Clean up logging
- [#23] Do not hash public keys
- [#34] Serverspec updates
- [#28] Add data bag caching option
- [#20] Add checspec matchers
- [#33] Add test to verify chefspec matcher

## v1.3.2 (2014-04-23)

- [COOK-4579] - Do not use ssh-keyscan stderr

## v1.3.0 (2014-04-09)

- [COOK-4489] Updated ssh-keyscan to include -t type

## v1.2.0 (2014-02-18)

### Bug

- **[COOK-3453](https://tickets.chef.io/browse/COOK-3453)** - ssh_known_hosts cookbook ruby block executes on every chef run

## v1.1.0

[COOK-3765] - support ssh-keyscan using an alternative port number

## v1.0.2

### Bug

- **[COOK-3113](https://tickets.chef.io/browse/COOK-3113)** - Use empty string when result is `nil`

## v1.0.0

This is a major release because it requires a server that supports the partial search feature.

- Chef Software Hosted Chef
- Chef Software Private Chef
- Open Source Chef 11

### Improvement

- [COOK-830]: uses an inordinate amount of RAM when running exception handlers

## v0.7.4

- [COOK-2440] - `ssh_known_hosts` fails to use data bag entries, doesn't grab items

## v0.7.2

- [COOK-2364] - Wrong LWRP name used in recipe

## v0.7.0

- [COOK-2320] - Merge `known_host` LWRP into `ssh_known_hosts`

## v0.6.0

- [COOK-2268] - Allow to run with chef-solo

## v0.5.0

- [COOK-1077] - allow adding arbitrary host keys from a data bag

## v0.4.0

- COOK-493: include fqdn
- COOK-721: corrected permissions
