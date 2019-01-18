require 'test_helper'

class ZabbixServiceTest < ActiveSupport::TestCase
  setup do
    ZabbixApi::Client.stub(:new, :zabbixapi_client) do
      @zabbix = ZabbixService.new(
          Struct.new(:server, :username, :password).new('server', 'username', 'password')
      )
    end

    # Change GRAPH_NAME_SORT_ORDER for tests
    ZabbixService.send(:remove_const, 'GRAPH_NAME_SORT_ORDER')
    ZabbixService.const_set('GRAPH_NAME_SORT_ORDER', %w{cpu memory timeout})
  end

  test 'connect should return Zabbix object' do
    assert_instance_of ZabbixApi, zabbixapi_instance
  end

  test 'connect should raise an exception if not connected' do
    raises_exception = -> (arg) {raise Net::OpenTimeout}
    ZabbixApi.stub(:connect, raises_exception) do
      assert_raises(Net::OpenTimeout) do
        ZabbixService.new(
            Struct.new(:server, :username, :password).new('server', 'username', 'password')
        )
      end
    end
  end

  test 'hostgroups should convert and sort' do
    @zabbix.stub(:hostgroups_all_query, hostgroups_unsorted_hash) do
      assert_equal hostgroups_sorted_array, @zabbix.hostgroups
    end
  end

  test 'hosts_by_hostgroup should process data' do
    zabbixapi_instance.stub(:query, hosts_query) do
      assert_equal hosts_processed, @zabbix.hosts_by_hostgroup(1)
    end
  end

  test 'host_names_by_ids should return Hash' do
    zabbixapi_instance.stub(:query, hosts_query) do
      assert_equal hosts_hash_expected, @zabbix.send('host_names_by_ids', %w{201 202})
    end
  end

  test 'sorted_graphs_by_host should sort' do
    zabbixapi_instance.stub(:query, graphs_query) do
      assert_equal sorted_graphs, @zabbix.send('sorted_graphs_by_host', 1)
    end
  end

  test 'hostgroups_all_query should call method all and return an array' do
    mock_hostgroups = Minitest::Mock.new
    mock_hostgroups.expect :all, [1, 2]
    zabbixapi_instance.stub(:hostgroups, mock_hostgroups) do
      assert_equal [1, 2], @zabbix.send('hostgroups_all_query')
    end
    assert_mock mock_hostgroups
  end

  test 'delete_screens should run delete_screen_query' do
    @zabbix.stub(:delete_screen_query, true) do
      assert_equal %w{hostname1 hostname2}, @zabbix.send('delete_screens', %w{hostname1 hostname2})
    end
  end

  test 'delete_screen_query should call ZabbixApi methods' do
    mock_zabbixapi = Minitest::Mock.new
    mock_zabbixapi.expect :delete, true, [Integer]
    mock_zabbixapi.expect :get_id, 101, [{name: 'hostname1'}]
    zabbixapi_instance.stub(:screens, mock_zabbixapi) do
      assert @zabbix.send(:delete_screen_query, 'hostname1')
    end
    assert_mock mock_zabbixapi
  end

  test 'create_screens should create them without replace' do
    @zabbix.stub(:host_names_by_ids, hosts_hash_expected, %w{201 202}) do
      @zabbix.stub(:sorted_graphs_by_host, sorted_graphs) do
        @zabbix.stub(:screen_create_query, true, 'TestHost-1', Array.new) do
          assert_equal create_screens_expected_result, @zabbix.create_screens(%w{201 202}, false)
        end
      end
    end
  end

  test 'create_screens should create them with replace' do
    @zabbix.stub(:host_names_by_ids, hosts_hash_expected, %w{201 202}) do
      @zabbix.stub(:delete_screens, true) do
        @zabbix.stub(:sorted_graphs_by_host, sorted_graphs) do
          @zabbix.stub(:screen_create_query, true, 'TestHost-1', Array.new) do
            assert_equal create_screens_expected_result, @zabbix.create_screens(%w{201 202}, true)
          end
        end
      end
    end
  end

  test 'screen_create_query should return true if ok' do
    zabbixapi_instance.stub(:query, true) do
      assert @zabbix.send(:screen_create_query, 'TestHost-1', [])
    end
  end

  test 'screen_create_query should return false if an Exception is occured' do
    assert_not @zabbix.send(:screen_create_query, 'TestHost-1', [])
  end

  private

  def create_screens_expected_result
    [ZabbixService::Result.new('TestHost-1', true, false),
     ZabbixService::Result.new('TestHost-2', true, false)]
  end

  def hostgroups_unsorted_hash
    {'xyz' => '10', 'abc' => '20'}
  end

  def hostgroups_sorted_array
    [%w{abc 20}, %w{xyz 10}]
  end

  def hosts_hash_expected
    {'201' => 'TestHost-1', '202' => 'TestHost-2'}
  end

  def hosts_query
    [{'hostid' => '201', 'proxy_hostid' => '0', 'host' => 'TestHost-1', 'status' => '0', 'disable_until' => '0', 'error' => '',
      'available' => '0', 'errors_from' => '0', 'lastaccess' => '0', 'ipmi_authtype' => '-1', 'ipmi_privilege' => '2',
      'ipmi_username' => '', 'ipmi_password' => '', 'ipmi_disable_until' => '0', 'ipmi_available' => '0',
      'snmp_disable_until' => '1528953911', 'snmp_available' => '2', 'maintenanceid' => '0',
      'maintenance_status' => '0', 'maintenance_type' => '0', 'maintenance_from' => '0', 'ipmi_errors_from' => '0',
      'snmp_errors_from' => '1517569374', 'ipmi_error' => '',
      'snmp_error' => 'Timeout while connecting to \'10.10.10.2:161\'.', 'jmx_disable_until' => '0',
      'jmx_available' => '0', 'jmx_errors_from' => '0', 'jmx_error' => '', 'name' => 'TestHost-1', 'flags' => '0',
      'templateid' => '0', 'description' => '', 'tls_connect' => '1', 'tls_accept' => '1', 'tls_issuer' => '',
      'tls_subject' => '', 'tls_psk_identity' => '', 'tls_psk' => '', 'interfaces' => [
            {'interfaceid' => '200200000001214', 'hostid' => '201', 'main' => '1', 'type' => '2', 'useip' => '1',
             'ip' => '10.10.10.2', 'dns' => '', 'port' => '161', 'bulk' => '1'}]},
     {'hostid' => '202', 'proxy_hostid' => '0', 'host' => 'TestHost-2', 'status' => '0', 'disable_until' => '0',
      'error' => '', 'available' => '0', 'errors_from' => '0', 'lastaccess' => '0', 'ipmi_authtype' => '-1',
      'ipmi_privilege' => '2', 'ipmi_username' => '', 'ipmi_password' => '', 'ipmi_disable_until' => '0',
      'ipmi_available' => '0', 'snmp_disable_until' => '0', 'snmp_available' => '1', 'maintenanceid' => '0',
      'maintenance_status' => '0', 'maintenance_type' => '0', 'maintenance_from' => '0', 'ipmi_errors_from' => '0',
      'snmp_errors_from' => '0', 'ipmi_error' => '', 'snmp_error' => '', 'jmx_disable_until' => '0',
      'jmx_available' => '0', 'jmx_errors_from' => '0', 'jmx_error' => '', 'name' => 'TestHost-2', 'flags' => '0',
      'templateid' => '0', 'description' => '', 'tls_connect' => '1', 'tls_accept' => '1', 'tls_issuer' => '',
      'tls_subject' => '', 'tls_psk_identity' => '', 'tls_psk' => '', 'interfaces' => [
         {'interfaceid' => '200200000001217', 'hostid' => '202', 'main' => '1', 'type' => '2', 'useip' => '1',
          'ip' => '10.10.10.3', 'dns' => '', 'port' => '161', 'bulk' => '1'}]}
    ]
  end

  def hosts_processed
    [ZabbixService::Host.new('201', 'TestHost-1', '10.10.10.2'),
     ZabbixService::Host.new('202', 'TestHost-2', '10.10.10.3')]
  end

  def zabbixapi_instance
    @zabbix.instance_variable_get(:@zabbix_instance)
  end

  def graphs_query
    [
        {'graphid' => '302', 'name' => 'Memory', 'width' => '900', 'height' => '200',
         'yaxismin' => '0.0000', 'yaxismax' => '100.0000', 'templateid' => '2001', 'show_work_period' => '1',
         'show_triggers' => '1', 'graphtype' => '0', 'show_legend' => '1', 'show_3d' => '0', 'percent_left' => '0.0000',
         'percent_right' => '0.0000', 'ymin_type' => '0', 'ymax_type' => '0', 'ymin_itemid' => '0', 'ymax_itemid' => '0',
         'flags' => '0'},
        {'graphid' => '303', 'name' => 'Timeout', 'width' => '900', 'height' => '200', 'yaxismin' => '0.0000',
         'yaxismax' => '100.0000', 'templateid' => '2002', 'show_work_period' => '1', 'show_triggers' => '1',
         'graphtype' => '0', 'show_legend' => '1', 'show_3d' => '0', 'percent_left' => '0.0000', 'percent_right' => '0.0000',
         'ymin_type' => '0', 'ymax_type' => '0', 'ymin_itemid' => '0', 'ymax_itemid' => '0', 'flags' => '0'},
        {'graphid' => '301', 'name' => 'CPU', 'width' => '900', 'height' => '200', 'yaxismin' => '0.0000',
         'yaxismax' => '100.0000', 'templateid' => '2003', 'show_work_period' => '1', 'show_triggers' => '1',
         'graphtype' => '0', 'show_legend' => '1', 'show_3d' => '0', 'percent_left' => '0.0000', 'percent_right' => '0.0000',
         'ymin_type' => '0', 'ymax_type' => '0', 'ymin_itemid' => '0', 'ymax_itemid' => '0', 'flags' => '0'}
    ]
  end

  def sorted_graphs
    [
        {'graphid' => '301', 'name' => 'CPU', 'width' => '900', 'height' => '200', 'yaxismin' => '0.0000',
         'yaxismax' => '100.0000', 'templateid' => '2003', 'show_work_period' => '1', 'show_triggers' => '1',
         'graphtype' => '0', 'show_legend' => '1', 'show_3d' => '0', 'percent_left' => '0.0000',
         'percent_right' => '0.0000', 'ymin_type' => '0', 'ymax_type' => '0', 'ymin_itemid' => '0',
         'ymax_itemid' => '0', 'flags' => '0'},
        {'graphid' => '302', 'name' => 'Memory', 'width' => '900', 'height' => '200', 'yaxismin' => '0.0000',
         'yaxismax' => '100.0000', 'templateid' => '2001', 'show_work_period' => '1', 'show_triggers' => '1',
         'graphtype' => '0', 'show_legend' => '1', 'show_3d' => '0', 'percent_left' => '0.0000',
         'percent_right' => '0.0000', 'ymin_type' => '0', 'ymax_type' => '0', 'ymin_itemid' => '0',
         'ymax_itemid' => '0', 'flags' => '0'},
        {'graphid' => '303', 'name' => 'Timeout', 'width' => '900', 'height' => '200', 'yaxismin' => '0.0000',
         'yaxismax' => '100.0000', 'templateid' => '2002', 'show_work_period' => '1', 'show_triggers' => '1',
         'graphtype' => '0', 'show_legend' => '1', 'show_3d' => '0', 'percent_left' => '0.0000',
         'percent_right' => '0.0000', 'ymin_type' => '0', 'ymax_type' => '0', 'ymin_itemid' => '0',
         'ymax_itemid' => '0', 'flags' => '0'}
    ]
  end
end