# Copyright [2019] [University of Aizu]
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

module Local
  private

  def local(role_dir)
    FileUtils.mkdir_p("#{role_dir}/metasploit")
    FileUtils.mkdir_p("#{role_dir}/metasploit/tasks")
    FileUtils.mkdir_p("#{role_dir}/metasploit/vars")
    FileUtils.mkdir_p("#{role_dir}/metasploit/files")
    FileUtils.cp_r(
      './lib/vulenv/tools/config/ansible/roles/metasploit/tasks/main.yml',
      "#{role_dir}/metasploit/tasks/main.yml"
    )
    FileUtils.cp_r(
      './lib/vulenv/tools/config/ansible/roles/metasploit/vars/main.yml',
      "#{role_dir}/metasploit/vars/main.yml"
    )
    FileUtils.cp_r(
      './lib/vulenv/tools/config/ansible/roles/metasploit/files/database.yml',
      "#{role_dir}/metasploit/files/database.yml"
    )
  end
end
