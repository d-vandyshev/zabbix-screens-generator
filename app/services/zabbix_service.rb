class ZabbixService
  def initialize(credentials)
    @zabbix_instance = connect(credentials.server, credentials.username, credentials.password)
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

  def create_screens(host_ids, with_replace)
    host_names = host_names_by_id(host_ids)
    delete_screens(host_names.values) if with_replace

    results = {}
    host_ids.each do |host_id|
      screenitems = []
      x = y = 0
      sorted_graphs_by_hostid(host_id).each do |graph|
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

  def host_names_by_id(host_ids)
    host_names = Hash.new
    @zabbix_instance.query(
        method: 'host.get',
        params: {
            hostids: host_ids
        }
    ).each do |host|
      host_names[host['hostid']] = host['host']
    end
    host_names
  end

  def sorted_graphs_by_hostid(host_id)
    graphs = @zabbix_instance.query(
        method: 'graph.get',
        params: {
            hostids: host_id
        }
    )
    graphs = graphs.sort_by {|graph| graph['name']}
    sorted_graphs = []
    %w(потери loss ответа timeout cpu memory uptime channel gigabit fast).each do |word|
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
end
