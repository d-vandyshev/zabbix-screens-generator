require 'test_helper'

class ZabbixServiceTest < ActiveSupport::TestCase
  include ZabbixApiHelper

  setup do
    ZabbixApi::Client.stub(:new, :zabbixapi_client) do
      credentials = Struct.new(:server, :username, :password).new('server', 'username', 'password')
      @zabbix = ZabbixConnection.new(credentials)
      @zabbix_service = ZabbixService.new(credentials)
    end

    # Change order_graph_by_name_for_screen for tests
    Rails.configuration.x.zabbix_service.order_graph_by_name_for_screen = %w[cpu memory timeout]
  end

  test 'hostgroups should convert and sort' do
    ZabbixConnection.stub_any_instance(:hostgroups_all_query, hostgroups_unsorted_hash) do
      assert_equal hostgroups_sorted_array, @zabbix_service.hostgroups
    end
  end

  test 'hosts_by_hostgroup should process data' do
    ZabbixConnection.stub_any_instance(:hosts_by_hostgroup_query, hosts_query) do
      assert_equal hosts_processed, @zabbix_service.hosts_by_hostgroup(1)
    end
  end

  test 'host_names_by_ids should return Hash' do
    ZabbixConnection.stub_any_instance(:hosts_by_id_query, hosts_query) do
      assert_equal hosts_hash_expected, @zabbix_service.send('host_names_by_ids', %w[201 202])
    end
  end

  test 'sorted_graphs_by_host should sort' do
    ZabbixConnection.stub_any_instance(:graphs_by_host_query, graphs_query) do
      assert_equal sorted_graphs, @zabbix_service.send('sorted_graphs_by_host', 1)
    end
  end

  test 'delete_screens should run delete_screen_query' do
    ZabbixConnection.stub_any_instance(:delete_screen_query, true) do
      assert_equal %w[hostname1 hostname2], @zabbix_service.send('delete_screens', %w[hostname1 hostname2])
    end
  end

  test 'create_screens should create them without replace' do
    @zabbix_service.stub(:host_names_by_ids, hosts_hash_expected, %w[201 202]) do
      @zabbix_service.stub(:sorted_graphs_by_host, sorted_graphs) do
        ZabbixConnection.stub_any_instance(:screen_create_query, true) do
          assert_equal create_screens_expected_result, @zabbix_service.create_screens(%w[201 202], false)
        end
      end
    end
  end

  test 'create_screens should create them with replace' do
    @zabbix_service.stub(:host_names_by_ids, hosts_hash_expected, %w[201 202]) do
      @zabbix_service.stub(:delete_screens, true) do
        @zabbix_service.stub(:sorted_graphs_by_host, sorted_graphs) do
          ZabbixConnection.stub_any_instance(:screen_create_query, true) do
            assert_equal create_screens_expected_result, @zabbix_service.create_screens(%w[201 202], true)
          end
        end
      end
    end
  end

  private

  def create_screens_expected_result
    [ZabbixService::Result.new('TestHost-1', true, false),
     ZabbixService::Result.new('TestHost-2', true, false)]
  end

  def hostgroups_sorted_array
    [%w[abc 20], %w[xyz 10]]
  end

  def hosts_hash_expected
    { '201' => 'TestHost-1', '202' => 'TestHost-2' }
  end

  def hosts_processed
    [ZabbixService::Host.new('201', 'TestHost-1', '10.10.10.2'),
     ZabbixService::Host.new('202', 'TestHost-2', '10.10.10.3')]
  end

  def sorted_graphs
    [
      { 'graphid' => '301', 'name' => 'CPU', 'width' => '900', 'height' => '200', 'yaxismin' => '0.0000',
        'yaxismax' => '100.0000', 'templateid' => '2003', 'show_work_period' => '1', 'show_triggers' => '1',
        'graphtype' => '0', 'show_legend' => '1', 'show_3d' => '0', 'percent_left' => '0.0000',
        'percent_right' => '0.0000', 'ymin_type' => '0', 'ymax_type' => '0', 'ymin_itemid' => '0',
        'ymax_itemid' => '0', 'flags' => '0' },
      { 'graphid' => '302', 'name' => 'Memory', 'width' => '900', 'height' => '200', 'yaxismin' => '0.0000',
        'yaxismax' => '100.0000', 'templateid' => '2001', 'show_work_period' => '1', 'show_triggers' => '1',
        'graphtype' => '0', 'show_legend' => '1', 'show_3d' => '0', 'percent_left' => '0.0000',
        'percent_right' => '0.0000', 'ymin_type' => '0', 'ymax_type' => '0', 'ymin_itemid' => '0',
        'ymax_itemid' => '0', 'flags' => '0' },
      { 'graphid' => '303', 'name' => 'Timeout', 'width' => '900', 'height' => '200', 'yaxismin' => '0.0000',
        'yaxismax' => '100.0000', 'templateid' => '2002', 'show_work_period' => '1', 'show_triggers' => '1',
        'graphtype' => '0', 'show_legend' => '1', 'show_3d' => '0', 'percent_left' => '0.0000',
        'percent_right' => '0.0000', 'ymin_type' => '0', 'ymax_type' => '0', 'ymin_itemid' => '0',
        'ymax_itemid' => '0', 'flags' => '0' }
    ]
  end
end
