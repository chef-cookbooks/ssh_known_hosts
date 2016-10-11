#
# Author:: Seth Vargo (<sethvargo@gmail.com>)
# Resource:: entry
#
# Copyright 2013, Seth Vargo
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

actions :create
default_action :create

attribute :host, kind_of: String, name_attribute: true
attribute :key, kind_of: String
attribute :key_type, kind_of: String, default: 'rsa'
attribute :port, kind_of: Fixnum, default: 22
attribute :timeout, kind_of: Fixnum, default: 30
attribute :mode, kind_of: String, default: '0644'
attribute :owner, kind_of: String, default: 'root'
attribute :group, kind_of: String, default: 'root'

action :create do
  key = if new_resource.key
    key_type = if new_resource.key_type == 'rsa' || new_resource.key_type == 'dsa'
                 "ssh-#{new_resource.key_type}"
               else
                 new_resource.key_type
               end

    hoststr = new_resource.port ? "[#{new_resource.host}]:#{new_resource.port}" : new_resource.host
    "#{hoststr} #{key_type} #{new_resource.key}"
  else
    keyscan = shell_out!("ssh-keyscan -t#{node['ssh_known_hosts']['key_type']} -p #{new_resource.port} #{new_resource.host}", timeout: new_resource.timeout)
    keyscan.stdout
  end

  key.sub!(/^#{new_resource.host}/, "[#{new_resource.host}]:#{new_resource.port}") if new_resource.port != 22

  comment = key.split("\n").first || ''

  r = with_run_context :root do
    # XXX: remove log resource once delayed_actions lands in compat_resource
    find_resource(:log, 'force delayed notification') do
      notifies :create, 'file[update ssh known hosts file]', :delayed
    end
    find_resource(:file, 'update ssh known hosts file') do
      path node['ssh_known_hosts']['file']
      owner new_resource.owner
      group new_resource.group
      mode new_resource.mode
      action :nothing
      backup false
      content ''
    end
  end

  keys = key_array(r.content)

  if key_exists?(keys, key, comment)
    Chef::Log.debug "Known hosts key for #{new_resource.name} already exists - skipping"
  else
    r.content keys.push(key).sort.uniq.join("\n") << "\n"
  end
end

action_class do
  def key_array(keystr)
    keystr.split("\n").reject(&:empty?)
  end

  def key_exists?(keys, key, comment)
    keys.any? do |line|
      line.match(/#{Regexp.escape(comment)}|#{Regexp.escape(key)}/)
    end
  end
end
