class ZabbixService
  def initialize(params)
    @zabbix_server = params[:zabbix_server]
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
    zabbix.hostgroups.all
  end

  private
  attr_reader :zabbix_server, :username, :password

  def connect
    ZabbixApi.connect(
        url: "http://#{@zabbix_server}/api_jsonrpc.php",
        user: @username,
        password: @password,
        timeout: 5
    )
  end
end