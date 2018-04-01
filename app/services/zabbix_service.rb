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
        if inet['main'] == '1'
          ip = inet['ip']
          break
        end
      end
      hosts << {
          name: host['name'],
          ip: ip,
          id: host['hostid']
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
