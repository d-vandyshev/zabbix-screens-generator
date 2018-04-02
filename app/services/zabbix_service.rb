class ZabbixService
  def initialize(params)
    @server = params[:server]
    @username = params[:username]
    @password = params[:password]
  end

  def auth_is_ok?
    # TODO move connect in initiliaze
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

  def create_screens(hosts_ids)
    hosts_ids.each do |host_id|
      puts "Get graphs ids for host id #{host_id}"
      # puts @zabbix_instance.graphs.get(hostids: [host_id]).inspect
      graphs = @zabbix_instance.query(
          method: 'graph.get',
          params: {
              hostids: host_id
          }
      )
      screenitems = []
      x = y = 0
      graphs.each do |graph|
        screenitems << {
            resourceid: graph['graphid'],
            resourcetype: 0,
            width: "700",
            height: "100",
            x: x,
            y: y
        }
        if x == 0
          x = 1
        elsif x == 1
          y += 1
          x = 0
        end
      end
      puts "Screenitems: #{screenitems}"

      @zabbix_instance.query(
          method: 'screen.create',
          params: {
              name: host_id.to_s,
              hsize: 2,
              vsize: screenitems.count / 2 + 1,
              screenitems: screenitems
              #     [
              #     {
              #         resourcetype: 0,
              #         resourceid: "200200000004294",
              #         width: "700",
              #         height: "100",
              #         x: 0,
              #         y: 0
              #     },
              #     {
              #         resourcetype: 0,
              #         resourceid: "200200000004295",
              #         width: "700",
              #         height: "100",
              #         x: 1,
              #         y: 0
              #     },
              #     {
              #         resourcetype: 0,
              #         resourceid: "100100000001252",
              #         width: "700",
              #         height: "100",
              #         x: 0,
              #         y: 1
              #     }
              # ]
          }
      )
      # TODO Create Screens with host name
      #
      # abort 'PLAN END'
      # + 1. get all graphs for this host
      # 2. sort them
      # 3. create screen with this graphs
    end

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
