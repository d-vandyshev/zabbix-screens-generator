class ZabbixService
  Host = Struct.new(:id, :name, :ip)
  Result = Struct.new(:hostname, :status, :excess_vsize?)

  def initialize(credentials)
    @zabbix = ZabbixConnection.new(credentials)
  end

  def hostgroups
    @hostgroups = @zabbix.hostgroups_all_query.sort.to_a
  end

  def hosts_by_hostgroup(id)
    hosts = []
    @zabbix.hosts_by_hostgroup_query(id).each do |host|
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
      screen_items = prepare_screen_items(host_id)

      # There is a Zabbix restriction of vsize. Value for field "vsize": must be between "1" and "100"
      excess_vsize = screen_items.size > 200
      screen_items = screen_items.first(200)

      results << Result.new(
        host_names[host_id],
        @zabbix.screen_create_query(host_names[host_id], screen_items),
        excess_vsize
      )
    end
    results
  end

  private

  def prepare_screen_items(host_id)
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
    screen_items
  end

  attr_reader :server, :username, :password

  #  Delete screens with names == host names
  def delete_screens(host_names)
    host_names.each { |name| @zabbix.delete_screen_query(name) }
  end

  def host_names_by_ids(host_ids)
    host_names = {}
    @zabbix.hosts_by_id_query(host_ids).each do |host|
      host_names[host['hostid']] = host['host']
    end
    host_names
  end

  def sorted_graphs_by_host(id)
    graphs = @zabbix.graphs_by_host_query(id).sort_by { |graph| graph['name'] }
    sorted_graphs = []
    order_words.each do |word|
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

  def method_name(order_match)
    order_match
  end

  def order_words
    Rails.configuration.x.zabbix_service.order_graph_by_name_for_screen
  end
end
