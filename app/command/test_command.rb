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

require './app/command/command'
require './lib/vultest_case'
require './lib/vulenv/control_vulenv'
require './modules/ui'

class TestCommand < Command
  attr_reader :cve, :vultest_case, :control_vulenv, :vulenv_dir

  def initialize(args)
    @cve = args[:cve]
    @vultest_case = args[:vultest_case]
    @control_vulenv = args[:control_vulenv]
    @vulenv_dir = args[:vulenv_dir]
  end

  def execute(&block)
    return unless vultest_case.nil?

    unless cve =~ /^(CVE|cve)-\d+\d+/i
      VultestUI.error('The CVE entered is incorrect')
      return
    end

    @vultest_case = prepare_vultest_case
    return unless vultest_case.select_test_case?

    @control_vulenv = prepare_control_vulenv
    VultestUI.warring('Can look at a report about error in construction of vulnerable environment') unless control_vulenv.create?

    block.call(cve: cve, vultest_case: vultest_case, control_vulenv: control_vulenv)
  end

  private

  def prepare_vultest_case
    VultestCase.new(cve: cve)
  end

  def prepare_control_vulenv
    ControlVulenv.new(
      cve: vultest_case.cve,
      config: vultest_case.config,
      vulenv_config: vultest_case.vulenv_config,
      vulenv_dir: vulenv_dir
    )
  end
end
