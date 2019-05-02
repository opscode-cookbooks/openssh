#
# Cookbook:: openssh
# library:: helpers
#
# Copyright:: 2016-2019, Chef Software, Inc.
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
# Attributes are commented out using the default config file values.
# Uncomment the ones you need, or set attributes in a role.
#

module Openssh
  module Helpers
    def openssh_server_options
      options = node['openssh']['server'].sort.reject { |key, _value| key == 'port' || key == 'match' || key == 'subsystem' }
      unless node['openssh']['server']['port'].nil?
        port = node['openssh']['server'].select { |key| key == 'port' }.to_a
        options.unshift(*port)
      end
      options
    end

    # are we on a platform that has the sshd-keygen command. It's a redhat-ism so it's a limited number
    def keygen_platform?
      return true if platform?('amazon', 'fedora')
      return true if platform_family?('rhel') && node['platform_version'].to_i >= 7
      platform_family?('suse') && node['platform_version'].to_i >= 15 && node['platform_version'].to_i < 42
    end

    # are any of the host keys defined in the attribute missing from the filesystem
    def sshd_host_keys_missing?
      !node['openssh']['server']['host_key'].all? { |f| ::File.exist?(f) }
    end

    def openssh_service_name
      if platform_family?('rhel', 'fedora', 'suse', 'freebsd', 'gentoo', 'arch', 'mac_os_x', 'amazon', 'aix')
        'sshd'
      else
        'ssh'
      end
    end

    def supports_use_roaming?
      return false if node['platform_family'] == 'rhel' && node['platform_version'].to_i < 7
      return false if node['platform_family'] == 'suse' && node['platform_version'].to_i >= 15 && node['platform_version'].to_i < 42
    end
  end
end

Chef::Resource.send(:include, ::Openssh::Helpers)
Chef::Recipe.send(:include, ::Openssh::Helpers)
Chef::Node.send(:include, ::Openssh::Helpers)
