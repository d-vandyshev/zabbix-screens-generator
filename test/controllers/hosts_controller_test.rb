require 'test_helper'

class HostsInHostgroupControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get hosts_in_hostgroup_show_url
    assert_response :success
  end
end
