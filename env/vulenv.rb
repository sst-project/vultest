require 'open3'
require 'tty-table'

require_relative '../db'
require_relative '../utility'
require_relative './tools/vagrant_ansible'

module Vulenv

  def create(vulenv_config_path, vulenv_dir)
    vulenv = VagrantAnsible.new(vulenv_config_path, vulenv_dir)
    vulenv_config_detail = YAML.load_file(vulenv_config_path)
    vulenv.create_vagrant_ansible_dir

    # start up environment of vulnerability
    Utility.print_message('execute', 'create vulnerability environment')
    Dir.chdir(vulenv_dir) do
      Utility.tty_spinner_begin('start up')
      stdout, stderr, status = Open3.capture3('vagrant up')

      if status.exitstatus != 0
        reload_stdout, reload_stderr, reload_status = Open3.capture3('vagrant reload')

        if reload_status.exitstatus != 0
          Utility.tty_spinner_end('error')
          return 'error'
        end
      end

      if vulenv_config_detail.key?('reload')
        reload_status, reload_stderr, reload_status = Open3.capture3('vagrant reload')
        if reload_status.exitstatus != 0 
          Utility.tty_spinner_end('error')
          return 'error'
        end
      end

      Utility.tty_spinner_end('success')

      # When tool cannot change setting, tool want user to change setting
      if vulenv_config_detail.key?('caution')
        vulenv_caution_setup_flag = false
        vulenv_config_detail['caution'].each do |vulenv_caution|
          if vulenv_caution['type'] == 'setup'
            vulenv_caution['msg'].each do |msg|
              Utility.print_message('caution', msg)
            end
            Open3.capture3('vagrant halt')
            vulenv_caution_setup_flag = true
          end
        end

        if vulenv_caution_setup_flag
          Utility.print_message('default','Please enter key when ready')
          input = gets

          Utility.tty_spinner_begin('reload')
          stdout, stderr, status = Open3.capture3('vagrant up')
          if status.exitstatus != 0
            Utility.tty_spinner_end('error')
            return 'error'
          end
          Utility.tty_spinner_end('success')
        end
      end
    end
  end

  def destroy(vulenv_dir)
    Dir.chdir(vulenv_dir) do
      Utility.tty_spinner_begin('vulent destroy')
      stdout, stderr, status = Open3.capture3('vagrant destroy -f')
      if status.exitstatus != 0
        Utility.tty_spinner_end('error')
        exit!
      end
    end

    stdout, stderr, status = Open3.capture3("rm -rf #{vulenv_dir}")
    if status.exitstatus != 0
      Utility.tty_spinner_end('error')
      exit!
    end

    Utility.tty_spinner_end('success')
  end

  def select(cve)
    vulconfigs = DB.get_vulconfigs(cve)

    table_index = 0
    vulenv_name_list = []
    vulenv_table = []
    vulenv_index_info = {}
    vulconfigs.each do |vulconfig|
      vulenv_table.push([table_index, vulconfig['name']])
      vulenv_index_info[vulconfig['name']] = table_index
      vulenv_name_list.push(vulconfig['name'])
      table_index += 1
    end

    return nil, nil if table_index == 0

    # Can create list which is environment of vulnerability
    Utility.print_message('output', 'vulnerability environment list')
    header = ['id', 'vulenv name']
    table = TTY::Table.new header, vulenv_table
    table.render(:ascii).each_line do |line|
      puts line.chomp
    end
    print "\n"

    # Select environment of vulnerability by id
    message = 'Select an id for testing vulnerability envrionment?'
    select_vulenv_name = Utility.tty_prompt(message, vulenv_name_list)
    select_id = vulenv_index_info[select_vulenv_name]

    config = Utility.get_config

    vulenv_config_path = "#{config['vultest_db_path']}/#{vulconfigs[select_id.to_i]['config_path']}"
    attack_config_path = "#{config['vultest_db_path']}/#{vulconfigs[select_id.to_i]['module_path']}"

    return vulenv_config_path, attack_config_path
  end

  module_function :create
  module_function :select
  module_function :destroy
end