class ZabbixService
  def initialize(params)
    @zabbix_server = params[:zabbix_server]
    @username = params[:username]
    @password = params[:password]
  end

  def auth_is_ok?
    ZabbixApi.connect(
        url: "http://#{@zabbix_server}/api_jsonrpc.php",
        user: @username,
        password: @password,
        timeout: 5
        )
    true
  rescue => e
    false
  end

  private
  attr_reader :zabbix_server, :username, :password
end