class ZabbixService
  def initialize(params)
    @server = params[:server]
    @username = params[:username]
    @password = params[:password]
  end

  def auth_is_ok?
    connect
    true
  rescue
    false
  end

  def hostgroups
    zabbix = connect
    zabbix.hostgroups.all.sort.to_a
  end

  def hosts_by_hostgroup_id(id)
    zabbix = connect
    zabbix.query(
        method: 'host.get',
        params: {groupids: id}
    )
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
