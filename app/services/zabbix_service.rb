class ZabbixService

  Host = Struct.new(:id, :name, :ip)
  GRAPH_NAME_SORT_ORDER = %w(потери loss ответа timeout cpu memory uptime channel gigabit fast)

  def initialize(credentials)
    @zabbix_instance = connect(credentials.server, credentials.username, credentials.password)
  end

  def hostgroups
    @hostgroups = hostgroups_all_query.sort.to_a
  end

  def hosts_by_hostgroup(id)
    hosts = []
    hosts_by_hostgroup_query(id).each do |host|
      ip = nil
      host['interfaces'].each do |inet|
        if inet['main'] == '1'
          ip = inet['ip']
          break
        end
      end
      hosts << Host.new(host['hostid'], host['name'], ip)
    end
    hosts
  end

  def create_screens(host_ids, with_replace)
    host_names = host_names_by_ids(host_ids)
    delete_screens(host_names.values) if with_replace

    results = {}
    host_ids.each do |host_id|
      screenitems = []
      x = y = 0
      sorted_graphs_by_host(host_id).each do |graph|
        screenitems << {
            resourceid: graph['graphid'],
            resourcetype: 0,
            width: '700',
            height: '100',
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
      is_success = true
      begin
        @zabbix_instance.query(
            method: 'screen.create',
            params: {
                name: host_names[host_id],
                hsize: 2,
                vsize: screenitems.count / 2 + 1,
                screenitems: screenitems
            }
        )
      rescue
        is_success = false
      end
      results[host_names[host_id]] = is_success
    end
    results
  end

  private

  attr_reader :server, :username, :password

  #  Delete screens with names == host names
  def delete_screens(host_names)
    host_names.each do |host_name|
      @zabbix_instance.screens.delete(
          @zabbix_instance.screens.get_id(name: host_name)
      )
    end
  end

  def connect(server, username, password)
    ZabbixApi.connect(
        url: "http://#{server}/api_jsonrpc.php",
        user: username,
        password: password,
        timeout: 5
    )
  end

  def host_names_by_ids(host_ids)
    host_names = Hash.new
    host_names_by_id_query(host_ids).each do |host|
      host_names[host['hostid']] = host['host']
    end
    host_names
  end

  def sorted_graphs_by_host(id)
    graphs = graphs_by_host_query(id).sort_by {|graph| graph['name']}
    sorted_graphs = []
    GRAPH_NAME_SORT_ORDER.each do |word|
      graphs.delete_if do |graph|
        if graph['name'].downcase.include? word
          sorted_graphs << graph
          true
        else
          false
        end
      end
    end
    sorted_graphs += graphs
  end

  def hostgroups_all_query
    @zabbix_instance.hostgroups.all
  end

  def hosts_by_hostgroup_query(id)
    @zabbix_instance.query(
        method: 'host.get',
        params: {
            'selectInterfaces' => 'extend',
            groupids: id
        }
    )
  end

  def host_names_by_id_query(host_ids)
    @zabbix_instance.query(
        method: 'host.get',
        params: {
            hostids: host_ids
        }
    )
  end

  def graphs_by_host_query(id)
    @zabbix_instance.query(
        method: 'graph.get',
        params: {
            hostids: id
        }
    )
  end
end
