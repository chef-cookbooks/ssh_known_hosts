#
# Author:: Seth Vargo (<sethvargo@gmail.com>)
# Provider:: entry
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
#

def whyrun_supported?
  true
end

action :create do
  key = (new_resource.key || `ssh-keyscan -H -p #{new_resource.port} #{new_resource.host} 2>&1`)
  comment = key.split("\n").first || ""

  Chef::Application.fatal! "Could not resolve #{new_resource.host}" if key =~ /getaddrinfo/

  unless key_exists?(key, comment)
    converge_by("add #{new_resource.name} to #{node['ssh_known_hosts']['file']}") do
      ::File.open(node['ssh_known_hosts']['file'], 'a') do |file|
        file.puts key
      end
    end
    new_resource.updated_by_last_action(true)
  end
end

private
  def key_file_exists?
    ::File.exists?(node['ssh_known_hosts']['file'])
  end

  def key_exists?(key, comment)
    return false unless key_file_exists?
    ::File.readlines(node['ssh_known_hosts']['file']).any? do |line|
      line.match(/#{Regexp.escape(comment)}|#{Regexp.escape(key)}/)
    end
  end
