class ZabbixConnection
  def initialize(credentials)
    @zabbix_instance = ZabbixApi.connect(
      url: "http://#{credentials.server}/api_jsonrpc.php",
      user: credentials.username,
      password: credentials.password,
      timeout: 5
    )
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

  def hosts_by_id_query(host_ids)
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

  def delete_screen_query(name)
    screen_id = @zabbix_instance.screens.get_id(name: name)
    @zabbix_instance.screens.delete(screen_id) unless screen_id.nil?
  end

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
    true
  rescue StandardError
    false
  end
end
