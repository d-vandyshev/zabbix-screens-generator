require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'before_action should run set_locale' do
    class ::TestxController < ApplicationController
      def testx
        render body: nil
      end
    end

    Rails.application.routes.draw do
      get 'test' => 'testx#testx'
    end
    ApplicationController.stub_any_instance(:locale_from_accept_lang_header, 'en') do
      get test_url
    end
    assert_not_nil @controller.instance_variable_get(:@available_locales) # [["EN", :en], ["RU", :ru]]
    assert_not_nil @controller.instance_variable_get(:@selected_locale) # :en
    Rails.application.reload_routes!
  end

  test 'locale_from_accept_lang_header should extract lang header' do
    @controller = ApplicationController.new
    mrequest = Minitest::Mock.new

    def mrequest.env
      { 'HTTP_ACCEPT_LANGUAGE' => 'en,ru;q=0.9,fi;q=0.8,be;q=0.7,vi;q=0.6' }
    end

    @controller.stub(:request, mrequest) do
      assert_equal 'en', @controller.send(:locale_from_accept_lang_header)
    end
  end

  test 'change_locale should change locale and redirect back' do
    ApplicationController.stub_any_instance(:set_locale, true) do
      demo_app_url = 'https://zabbix-screens-gen.herokuapp.com'
      post '/change_locale',
           params: { locale: { locale: 'ru' } },
           headers: { 'HTTP_REFERER' => demo_app_url }
      assert_equal :ru, session[:locale]
      assert_response :redirect
      assert_equal demo_app_url, @response.location
    end
  end
end
