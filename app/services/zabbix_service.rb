class ZabbixService
  def initialize(params)
    @server = params[:server]
    @username = params[:username]
    @password = params[:password]
  end

  def auth_is_ok?
    @zabbix_instance = connect
    true
  rescue
    false
  end

  def hostgroups
    @hostgroups ||= @zabbix_instance.hostgroups.all.sort.to_a
  end

  # hosts_from_api = @zabbix.query(
  #     method: 'host.get',
  #     params: {
  #         'output' => 'extend',
  #         'selectGroups' => 'extend',
  #         'selectMacros' => 'extend',
  #         'selectInterfaces' => 'extend',
  #         'selectParentTemplates' => %w(templateid name),
  #         'groupids' => [@zabbix.hostgroups.get_id(name: @common_group)]
  #     }
  # )

  def hosts_by_hostgroup_id(id)
    hosts_raw = @zabbix_instance.query(
        method: 'host.get',
        params: {
            'selectInterfaces' => 'extend',
            groupids: id
        }
    )
    hosts = []
    hosts_raw.each do |host|
      ip = nil
      host['interfaces'].each do |inet|
        puts 'in interfaces. main class and val'
        puts inet['main'].class
        puts inet['main'].inspect
        if inet['main'] == '1'
          puts 'main = 1'
          puts 'ip:'
          puts inet['ip']
          ip = inet['ip']
          break
        end
      end
      hosts << {
          name: host['name'],
          ip: ip
      }
    end
    hosts
  end

  private
  attr_reader :server, :username, :password

  def connect
    ZabbixApi.connect(
        url: "http://#{@server}/api_jsonrpc.php",
        user: @username,
        password: @password,
        timeout: 5
    )
  end
end
