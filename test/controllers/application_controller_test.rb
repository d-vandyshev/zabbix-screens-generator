require 'test_helper'

class ApplicationController < ActionController::Base
  def action
    render body: nil
  end
end

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.routes.draw do
      get 'check_action' => 'application#action'
    end
  end

  test 'before_action should run :set_locale' do
    @controller.stub(:set_locale, true) do
      get check_action_url
    end
  end
end