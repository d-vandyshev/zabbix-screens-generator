require 'test_helper'

class ZabbixConnectionTest < ActiveSupport::TestCase
  include ZabbixApiHelper

  setup do
    ZabbixApi::Client.stub(:new, :zabbixapi_client) do
      @zabbix = ZabbixConnection.new(
        Struct.new(:server, :username, :password).new('server', 'username', 'password')
      )
    end
  end

  test 'hostgroups_all_query should call method all and return an array' do
    mock_hostgroups = Minitest::Mock.new
    mock_hostgroups.expect :all, [1, 2]
    zabbixapi.stub(:hostgroups, mock_hostgroups) do
      assert_equal [1, 2], @zabbix.send('hostgroups_all_query')
    end
    assert_mock mock_hostgroups
  end

  test 'delete_screen_query should call ZabbixApi methods' do
    mock_zabbixapi = Minitest::Mock.new
    mock_zabbixapi.expect :delete, true, [Integer]
    mock_zabbixapi.expect :get_id, 101, [{ name: 'hostname1' }]
    zabbixapi.stub(:screens, mock_zabbixapi) do
      assert @zabbix.send(:delete_screen_query, 'hostname1')
    end
    assert_mock mock_zabbixapi
  end

  test 'screen_create_query should return true if ok' do
    zabbixapi.stub(:query, true) do
      assert @zabbix.send(:screen_create_query, 'TestHost-1', [])
    end
  end

  test 'screen_create_query should return false if an Exception is occured' do
    assert_not @zabbix.send(:screen_create_query, 'TestHost-1', [])
  end

  test 'hosts_by_hostgroup_query should return hosts' do
    zabbixapi.stub(:query, hosts_query) do
      assert_equal hosts_query, @zabbix.send('hosts_by_hostgroup_query', 1)
    end
  end

  test 'hosts_by_id_query should return hosts' do
    zabbixapi.stub(:query, hosts_query) do
      assert_equal hosts_query, @zabbix.send('hosts_by_id_query', [1, 2])
    end
  end

  test 'graphs_by_host_query should return graphs' do
    zabbixapi.stub(:query, graphs_query) do
      assert_equal graphs_query, @zabbix.send('graphs_by_host_query', 1)
    end
  end

  private

  def zabbixapi
    @zabbix.instance_variable_get(:@zabbix_instance)
  end
end
