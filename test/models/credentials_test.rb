require 'test_helper'

class CredentialsTest < ActiveSupport::TestCase
  test "should have presence validator" do
    creds = Credentials.new
    assert_not creds.valid?
    assert_equal [:server, :username, :password], creds.errors.keys
  end
end
