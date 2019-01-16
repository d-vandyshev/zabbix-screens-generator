require 'test_helper'

class ScreensControllerTest < ActionDispatch::IntegrationTest
  test 'before_action should call require_login and redirect to root' do
    ScreensController.stub_any_instance(:logged_in?, false) do
      get screens_new_url
    end
    assert_redirected_to root_path
    assert_not flash[:danger].nil?
  end

  test 'get new should set hostgroups and hostgroup_is_selected' do
    mock_zabbix = Minitest::Mock.new
    mock_zabbix.expect :hostgroups, []
    ScreensController.stub_any_instance(:logged_in?, true) do
      ScreensController.stub_any_instance(:zabbix_from_cache, mock_zabbix) do
        get screens_new_url
      end
    end
    assert_mock mock_zabbix
    assert_equal false, @controller.instance_variable_get(:@hostgroup_is_selected)
    assert_response :success
  end

  test 'post new should get hosts and show them' do
    mock_zabbix = Minitest::Mock.new
    mock_zabbix.expect :hostgroups, []
    mock_zabbix.expect :hosts_by_hostgroup, [], [String]
    ScreensController.stub_any_instance(:logged_in?, true) do
      ScreensController.stub_any_instance(:zabbix_from_cache, mock_zabbix) do
        post screens_new_url, params: {hostgroup: {id: 10}}
      end
    end
    assert_equal true, @controller.instance_variable_get(:@hostgroup_is_selected)
    assert_equal [], @controller.instance_variable_get(:@hosts)
    assert_equal false, @controller.instance_variable_get(:@hostgroup_with_hosts)
    assert_equal '10', @controller.instance_variable_get(:@hostgroup_id)
  end

  test 'create should call zabbix create' do
    mock_zabbix = Minitest::Mock.new
    result = [
        ZabbixService::Result.new('name200', true, false),
        ZabbixService::Result.new('name201', false, true)
    ]
    params_host_ids_result = [%w{200 201}, true]
    mock_zabbix.expect :create_screens, result, params_host_ids_result
    ScreensController.stub_any_instance(:logged_in?, true) do
      ScreensController.stub_any_instance(:zabbix_from_cache, mock_zabbix) do
        post screens_create_url, params: {host_ids: [200, 201], with_replace: true}
      end
    end
    assert_equal params_host_ids_result, @controller.send(:params_host_ids)
    assert_equal result, @controller.instance_variable_get(:@results)
    assert_mock mock_zabbix
  end

  test 'zabbix_from_cache return zabbix object' do
    ZabbixTestApi = Struct.new(:test)
    zabbix_api = ZabbixTestApi.new('test')
    Rails.cache.write('uuid1010', zabbix_api)
    ScreensController.stub_any_instance(:logged_in?, false) do
      get screens_new_url
    end
    session[:uuid] = 'uuid1010'
    assert_equal zabbix_api, @controller.send(:zabbix_from_cache)
  end
end
