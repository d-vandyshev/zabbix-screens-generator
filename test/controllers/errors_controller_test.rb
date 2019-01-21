require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "incident page_not_found should call their method" do
    get '/unknown-url'
    assert_response :missing

    get '/404'
    assert_response :missing
  end

  test "incident internal_server_error should call their method" do
    class ::TestxController < ApplicationController
      def testx
        raise StandardError
      end
    end
    Rails.application.routes.draw do
      get 'test' => 'testx#testx'
    end
    get test_url
    assert_response :error
    Rails.application.reload_routes!

    get '/500'
    assert_response :error
  end
end
