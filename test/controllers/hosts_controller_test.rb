require 'test_helper'

class HostsControllerTest < ActionDispatch::IntegrationTest
  test 'before_action should call require_login and redirect to root' do
    HostsController.stub_any_instance(:logged_in?, false) do
      get hosts_url
    end
    assert_redirected_to root_path
    assert_not flash[:danger].nil?
  end

  test 'get hosts should render empty when there are no hosts' do
    zabbix = Minitest::Mock.new
    zabbix.expect(:hosts_by_hostgroup, [], ['20'])
    HostsController.stub_any_instance(:logged_in?, true) do
      HostsController.stub_any_instance(:zabbix_from_cache, zabbix) do
        get hosts_url, params: { hostgroup_id: 20 }, xhr: true
      end
    end
    zabbix.verify
    assert_response :success
    assert_equal 'index', @controller.action_name
    assert_match I18n.t('generator.no_hosts_in_group'), @response.body
  end

  test 'get hosts should render index when hosts exists' do
    zabbix = Minitest::Mock.new
    zabbix.expect(:hosts_by_hostgroup, hosts_processed, ['20'])
    HostsController.stub_any_instance(:logged_in?, true) do
      HostsController.stub_any_instance(:zabbix_from_cache, zabbix) do
        get hosts_url, params: { hostgroup_id: 20 }, xhr: true
      end
    end
    zabbix.verify
    assert_response :success
    assert_equal 'index', @controller.action_name
    assert_match I18n.t('generator.replace_screen_if_exist'), @response.body
  end

  private

  def hosts_processed
    [ZabbixService::Host.new('201', 'TestHost-1', '10.10.10.2'),
     ZabbixService::Host.new('202', 'TestHost-2', '10.10.10.3')]
  end
end
