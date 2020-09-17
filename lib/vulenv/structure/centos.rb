# Copyright [2020] [University of Aizu]
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
require 'net/ssh'

module Vulenv
  module Structure
    class CentOS
      def initialize(args)
        @host = args[:host]
        @user = args[:user]
        @password = args[:password]
        @env_config = args[:env_config]
      end

      def retrieve_os
        major_version =
          Net::SSH.start(@host, @user, password: @password, verify_host_key: :never) do |ssh|
            ssh.exec!('uname -r')
          end

        {
          name: @env_config['host']['os']['name'],
          version: @env_config['host']['os']['version'],
          major_version: major_version,
          vulnerability: @env_config['host']['os']['vulnerability']
        }
      end

      def retrieve_vul_software
        return { name: nil, version: nil } unless @env_config['host'].key?('softwares')

        v = @env_config['host']['softwares'].find do |s|
          s.key?('vulnerability') && s['vulnerability']
        end

        { name: v['name'], version: v['version'] }
      end

      def retrieve_related_softwares
        return [] unless @env_config['host'].key?('softwares')

        softwares = create_related_software_list(@env_config['host']['softwares'])

        related_softwares = {}
        Net::SSH.start(@host, @user, password: @password, verify_host_key: :never) do |ssh|
          related_softwares = softwares.map do |software|
            if software[:version] == 'The latest version of the repository'
              cmd = "sudo yum list installed | grep \"^#{software[:name]}.\""
              v = ssh.exec!(cmd).split(' ')[1]
              software[:version] = v unless v.nil?
            end
            { name: software[:name], version: software[:version] }
          end
        end

        related_softwares
      end

      def create_related_software_list(softwares)
        res = []
        softwares.each do |software|
          if software.key?('vulnerability') && software['vulnerability']
            res += create_related_software_list(software['softwares']) if software.key?('softwares')
            next
          end

          no_version = 'The latest version of the repository'
          res.push({ name: software['name'], version: software.fetch('version', no_version) })

          res += create_related_software_list(software['softwares']) if software.key?('softwares')
        end
        res
      end

      def retrieve_ipaddrs
        ipaddrs = []
        Net::SSH.start(@host, @user, password: @password, verify_host_key: :never) do |ssh|
          cmd = ssh.exec!('sudo find / -name ip 2> /dev/null | grep bin/').split("\n")[0]
          cmd += ' addr | grep inet'

          ssh.exec!(cmd).split("\n").each_slice(2) do |ip|
            ipaddrs.push(
              {
                interface: ip[0].split(' ')[-1],
                inet: ip[0].split(' ')[1],
                inet6: ip[1].split(' ')[1]
              }
            )
          end
        end
        ipaddrs
      end

      def retrieve_services
        services = []
        Net::SSH.start(@host, @user, password: 'vagrant', verify_host_key: :never) do |ssh|
          cmd = ssh.exec!('sudo find / -name service 2> /dev/null | grep bin/').split("\n")[0]
          cmd = "sudo #{cmd} --status-all | grep running..."
          services = ssh.exec!(cmd).split("\n").map { |stdout| stdout.split(' ')[0] }
        end

        services
      end

      def retrieve_port_list
        port_list = []
        Net::SSH.start(@host, @user, password: @password, verify_host_key: :never) do |ssh|
          cmd = ssh.exec!('sudo find / -name ss 2> /dev/null | grep bin/').split("\n")[0]

          socket_service_stdout = ssh.exec!("#{cmd} -atu").split("\n")
          ssh.exec!("#{cmd} -antu").split("\n").each_with_index do |stdout, index|
            next if index.zero?

            service = socket_service_stdout[index].split(' ')[4].split(':')[-1]

            stdout_array = stdout.split(' ')
            protocol = stdout_array[0]
            port = stdout_array[4].split(':')[-1]

            next unless port_list.find { |s| s[:port] == port }.nil?

            port_list.push({ protocol: protocol, port: port, service: service })
          end
        end

        port_list
      end
    end
  end
end
