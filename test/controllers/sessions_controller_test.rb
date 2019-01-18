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
    class MockZabbixApiConnected < String # For pass many checks of value in Rails.cache.write()
      def connected?
        true
      end
    end
    mock_zabbixapi = MockZabbixApiConnected.new('zabbixapi')
    ZabbixService.stub(:new, mock_zabbixapi) do
      post '/', params: {credentials: {server: 'server', username: 'username', password: 'password'}}
    end
    assert_instance_of Credentials, @controller.instance_variable_get(:@credentials)
    assert_redirected_to screens_new_path

    # test set_session from SessionsHelper module
    assert_instance_of String, session[:uuid]
    assert_equal 'username', session[:username]
    assert_equal 'zabbixapi', Rails.cache.read(session[:uuid])
  end

  test 'create should render new when unable to connect' do
    raises_exception = -> {raise Net::OpenTimeout}
    ZabbixApi.stub(:connect, raises_exception) do
      post '/', params: {credentials: {server: '192.168.1.2', username: 'username', password: 'password'}}
    end
    assert_not flash.empty?
    assert_response :success
  end

  test 'create should render new if not valid?' do
    SessionsController.stub_any_instance(:set_session, true) do
      post root_url, params: {credentials: {server: 's/erver', username: 'us?er&name', password: 'password'}}
    end
    assert_response :success
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
