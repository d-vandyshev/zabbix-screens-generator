require 'test_helper'

class ScreensControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get screens_new_url
    assert_response :success
  end

  test "should get create" do
    get screens_create_url
    assert_response :success
  end

end
