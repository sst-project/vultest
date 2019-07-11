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

require 'bundler/setup'
require 'sqlite3'

module DB
  @config = YAML.load_file('./config.yml')

  class << self
    def get_cve_info(cve)
      db = SQLite3::Database.new("#{@config['vultest_db_path']}/db/cve.sqlite3")
      db.results_as_hash = true
      cve_info = {}

      db.execute('select * from cve where cve=?', cve) do |info|
        cve_info['nvd_id'] = info['nvd_id']
        cve_info['description'] = info['description']
      end
      db.close

      cve_info
    end

    def get_cwe(cve)
      db = SQLite3::Database.new("#{@config['vultest_db_path']}/db/cwe.sqlite3")
      db.results_as_hash = true
      cwe = nil
      db.execute('select * from cwe where cve=?', cve) { |cwe_info| cwe = cwe.nil? ? cwe_info['cwe'] : "#{cwe}\n#{cwe_info['cwe']}" }
      db.close

      cwe
    end

    def get_cpe(cve)
      db = SQLite3::Database.new("#{@config['vultest_db_path']}/db/cpe.sqlite3")
      db.results_as_hash = true
      cpe = []
      db.execute('select * from cpe where cve=?', cve) { |cpe_info| cpe << cpe_info['cpe'] }
      db.close

      cpe
    end

    def get_cvss_v2(cve)
      db = SQLite3::Database.new("#{@config['vultest_db_path']}/db/cvss_v2.sqlite3")
      db.results_as_hash = true
      cvss_v2 = {}
      db.execute('select * from cvss_v2 where cve=?', cve) do |cvss|
        cvss_v2['vector'] = cvss['vector_string']
        cvss_v2['access_vector'] = cvss['access_vector']
        cvss_v2['access_complexity'] = cvss['access_complexity']
        cvss_v2['authentication'] = cvss['authentication']
        cvss_v2['confidentiality_impact'] = cvss['confidentiality_impact']
        cvss_v2['integrity_impact'] = cvss['integrity_impact']
        cvss_v2['availability_impact'] = cvss['availability_impact']
        cvss_v2['base_score'] = cvss['base_score']
      end
      db.close

      cvss_v2
    end

    def get_cvss_v3(cve)
      db = SQLite3::Database.new("#{@config['vultest_db_path']}/db/cvss_v3.sqlite3")
      db.results_as_hash = true
      cvss_v3 = {}

      db.execute('select * from cvss_v3 where cve=?', cve) do |cvss|
        cvss_v3['vector'] = cvss['vector_string']
        cvss_v3['attack_vector'] = cvss['attack_vector']
        cvss_v3['attack_complexity'] = cvss['attack_complexity']
        cvss_v3['privileges_required'] = cvss['privileges_required']
        cvss_v3['user_interaction'] = cvss['user_interaction']
        cvss_v3['scope'] = cvss['scope']
        cvss_v3['confidentiality_impact'] = cvss['confidentiality_impact']
        cvss_v3['integrity_impact'] = cvss['integrity_impact']
        cvss_v3['availability_impact'] = cvss['availability_impact']
        cvss_v3['base_score'] = cvss['base_score']
        cvss_v3['base_severity'] = cvss['base_severity']
      end
      db.close

      cvss_v3
    end

    def get_vul_configs(cve)
      db = SQLite3::Database.new("#{@config['vultest_db_path']}/db/vultest.sqlite3")
      db.results_as_hash = true

      vul_configs = []
      db.execute('select * from configs where cve=?', cve) do |config|
        vul_config = {}
        vul_config['name'] = config['name']
        vul_config['config_path'] = config['config_path']
        vul_config['module_path'] = config['module_path']
        vul_configs << vul_config
      end
      db.close
      vul_configs
    end
  end
end
