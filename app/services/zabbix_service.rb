class ZabbixService
  Host = Struct.new(:id, :name, :ip)
  Result = Struct.new(:hostname, :status, :excess_vsize?)
  GRAPH_NAME_SORT_ORDER = %w[потери loss ответа timeout cpu memory uptime channel gigabit fast].freeze

  def initialize(credentials)
    @zabbix_instance = ZabbixApi.connect(
      url: "http://#{credentials.server}/api_jsonrpc.php",
      user: credentials.username,
      password: credentials.password,
      timeout: 5
    )
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

    results = []
    host_ids.each do |host_id|
      screen_items = []
      x = y = 0
      sorted_graphs_by_host(host_id).each do |graph|
        screen_items << {
          resourceid: graph['graphid'],
          resourcetype: 0,
          width: '700',
          height: '100',
          x: x,
          y: y
        }
        if x.zero?
          x = 1
        elsif x == 1
          y += 1
          x = 0
        end
      end

      # There is a Zabbix restriction of vsize. Value for field "vsize": must be between "1" and "100"
      excess_vsize = screen_items.size > 200
      screen_items = screen_items.first(200)

      results << Result.new(
        host_names[host_id],
        screen_create_query(host_names[host_id], screen_items),
        excess_vsize
      )
    end
    results
  end

  private

  def screen_create_query(screen_name, screen_items)
    vsize = screen_items.count / 2
    vsize += 1 if screen_items.count.odd?

    @zabbix_instance.query(
      method: 'screen.create',
      params: {
        name: screen_name,
        hsize: 2,
        vsize: vsize,
        screenitems: screen_items
      }
    )
    return true
  rescue
    return false
  end

  attr_reader :server, :username, :password

  #  Delete screens with names == host names
  def delete_screens(host_names)
    host_names.each { |name| delete_screen_query(name) }
  end

  def delete_screen_query(name)
    screen_id = @zabbix_instance.screens.get_id(name: name)
    @zabbix_instance.screens.delete(screen_id) unless screen_id.nil?
  end

  def host_names_by_ids(host_ids)
    host_names = {}
    host_names_by_id_query(host_ids).each do |host|
      host_names[host['hostid']] = host['host']
    end
    host_names
  end

  def sorted_graphs_by_host(id)
    graphs = graphs_by_host_query(id).sort_by { |graph| graph['name'] }
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
