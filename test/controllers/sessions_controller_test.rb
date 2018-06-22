require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'new should redirect if logged_in? and create instance of Credentials' do
    SessionsController.stub_any_instance(:logged_in?, true) do
      get root_url
    end
    assert_redirected_to screens_new_path
    assert_instance_of Credentials, @controller.instance_variable_get(:@credentials)
  end

  test 'new should show form' do
    SessionsController.stub_any_instance(:logged_in?, false) do
      get root_url
    end
    assert_response :success
  end

  test 'create should set_session and redirect if valid?' do
    ZabbixService.stub(:new, :zabbixapi) do
      SessionsController.stub_any_instance(:set_session, true) do
        post '/', params: {credentials: {server: 'server', username: 'username', password: 'password'}}
      end
    end
    assert_instance_of Credentials, @controller.instance_variable_get(:@credentials)
    assert_redirected_to screens_new_path
  end

  test 'create should render new and flash if not valid?' do
    ZabbixService.stub(:new, :zabbixapi) do
      SessionsController.stub_any_instance(:set_session, true) do
        post root_url, params: {credentials: {server: 's/erver', username: 'us?er&name', password: 'password'}}
      end
    end
    assert_response :success
  end

  test 'create should render new when Exception is occured' do
    class ::ZabbixService
      alias_method :ini, :initialize
      def initialize(param)
        raise 'Exception in connect'
      end
    end

    SessionsController.stub_any_instance(:set_session, true) do
      post '/', params: {credentials: {server: 'server', username: 'username', password: 'password'}}
    end
    assert_not flash.empty?
    assert_response :success

    class ::ZabbixService
      alias_method :initialize, :ini
    end
  end

  test 'destroy should destroy_session flash and redirect' do
    SessionsController.stub_any_instance(:destroy_session, :true) do
      delete logout_url
    end
    assert_not flash.empty?
    assert_redirected_to root_url
  end
end
