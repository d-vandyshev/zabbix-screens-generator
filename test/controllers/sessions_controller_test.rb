require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'new should redirect if logged_in? and create instance of Credentials' do
    SessionsController.stub_any_instance(:logged_in?, true) do
      get root_url
    end
    assert_redirected_to screens_new_path
    assert_instance_of Credentials, @controller.instance_variable_get(:@credentials)
  end

  test 'new should show form in not logged_in?' do
    SessionsController.stub_any_instance(:logged_in?, false) do
      get root_url
    end
    assert_response :success

    # test logged_in? from SessionsHelper module
    assert_not @controller.logged_in?
    session[:uuid] = 'uuid2335'
    Rails.cache.write(session[:uuid], 'uuid2335')
    assert @controller.logged_in?
  end

  test 'create should set_session and redirect if valid?' do
    ZabbixService.stub(:new, :zabbixapi) do
      post '/', params: {credentials: {server: 'server', username: 'username', password: 'password'}}
    end
    assert_instance_of Credentials, @controller.instance_variable_get(:@credentials)
    assert_redirected_to screens_new_path

    # test set_session from SessionsHelper module
    assert_instance_of String, session[:uuid]
    assert_equal 'username', session[:username]
    assert_equal :zabbixapi, Rails.cache.read(session[:uuid])
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
    delete logout_url
    assert_not flash.empty?
    assert_redirected_to root_url

    # test destroy_session from SessionsHelper module
    assert_nil Rails.cache.read(session[:uuid])
    assert_nil session[:uuid]
    assert_nil session[:username]
  end
end
