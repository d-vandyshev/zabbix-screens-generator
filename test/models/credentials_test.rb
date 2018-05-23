require 'test_helper'

class CredentialsTest < ActiveSupport::TestCase
  test "should have presence validator" do
    creds = Credentials.new
    assert_not creds.valid?
    assert_equal [:server, :username, :password], creds.errors.keys
  end

  test "server and username should be valid without special characters" do
    %w[1.1.1.1 zabbix первый-admin].each do |str|
      creds = Credentials.new(server: str, username: str, password: 'passw')
      assert creds.valid?
    end
  end

  test "server and username should be invalid with special characters" do
    %w[http://1.1.1.1 zab*bix adm&%$in].each do |str|
      creds = Credentials.new(server: str, username: str, password: 'passw')
      assert_not creds.valid?
    end
  end
end
