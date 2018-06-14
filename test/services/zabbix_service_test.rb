require 'minitest/autorun'
require 'test_helper'

class ZabbixServiceTest < ActiveSupport::TestCase
  setup do
    @credentials = Struct.new(:server, :username, :password).new('server', 'username', 'password')
    ZabbixApi.stub(:connect, :zabbixapi) do
      @zabbix = ZabbixService.new(@credentials)
    end
  end

  test 'connect should return Zabbix object' do
    assert @zabbix.instance_variable_get(:@zabbix_instance).eql? :zabbixapi
  end

  test 'hostgroups should convert and sort' do
    @zabbix.stub(:hostgroups_all, hostgroups_unsorted_hash) do
      assert @zabbix.hostgroups.eql? hostgroups_sorted_array
    end
  end

  test 'hosts_by_hostgroup should process data' do
    @zabbix.stub(:hosts_by_hostgroup_raw, hosts_raw) do
      assert @zabbix.hosts_by_hostgroup(1).eql? hosts_processed
    end
  end

  private

  def hostgroups_unsorted_hash
    {'xyz' => '10', 'abc' => '20'}
  end

  def hostgroups_sorted_array
    [%w{abc 20}, %w{xyz 10}]
  end

  def hosts_raw
    [{'hostid' => '201', 'proxy_hostid' => '0', 'host' => 'TestHost-1', 'status' => '0', 'disable_until' => '0', 'error' => '',
      'available' => '0', 'errors_from' => '0', 'lastaccess' => '0', 'ipmi_authtype' => '-1', 'ipmi_privilege' => '2',
      'ipmi_username' => '', 'ipmi_password' => '', 'ipmi_disable_until' => '0', 'ipmi_available' => '0',
      'snmp_disable_until' => '1528953911', 'snmp_available' => '2', 'maintenanceid' => '0',
      'maintenance_status' => '0', 'maintenance_type' => '0', 'maintenance_from' => '0', 'ipmi_errors_from' => '0',
      'snmp_errors_from' => '1517569374', 'ipmi_error' => '',
      'snmp_error' => 'Timeout while connecting to \'10.10.10.2:161\'.', 'jmx_disable_until' => '0',
      'jmx_available' => '0', 'jmx_errors_from' => '0', 'jmx_error' => '', 'name' => 'TestHost-1', 'flags' => '0',
      'templateid' => '0', 'description' => '', 'tls_connect' => '1', 'tls_accept' => '1', 'tls_issuer' => '',
      'tls_subject' => '', 'tls_psk_identity' => '', 'tls_psk' => '', 'interfaces' => [
            {'interfaceid' => '200200000001214', 'hostid' => '201', 'main' => '1', 'type' => '2', 'useip' => '1',
             'ip' => '10.10.10.2', 'dns' => '', 'port' => '161', 'bulk' => '1'}]},
     {'hostid' => '202', 'proxy_hostid' => '0', 'host' => 'TestHost-2', 'status' => '0', 'disable_until' => '0',
      'error' => '', 'available' => '0', 'errors_from' => '0', 'lastaccess' => '0', 'ipmi_authtype' => '-1',
      'ipmi_privilege' => '2', 'ipmi_username' => '', 'ipmi_password' => '', 'ipmi_disable_until' => '0',
      'ipmi_available' => '0', 'snmp_disable_until' => '0', 'snmp_available' => '1', 'maintenanceid' => '0',
      'maintenance_status' => '0', 'maintenance_type' => '0', 'maintenance_from' => '0', 'ipmi_errors_from' => '0',
      'snmp_errors_from' => '0', 'ipmi_error' => '', 'snmp_error' => '', 'jmx_disable_until' => '0',
      'jmx_available' => '0', 'jmx_errors_from' => '0', 'jmx_error' => '', 'name' => 'TestHost-2', 'flags' => '0',
      'templateid' => '0', 'description' => '', 'tls_connect' => '1', 'tls_accept' => '1', 'tls_issuer' => '',
      'tls_subject' => '', 'tls_psk_identity' => '', 'tls_psk' => '', 'interfaces' => [
         {'interfaceid' => '200200000001217', 'hostid' => '202', 'main' => '1', 'type' => '2', 'useip' => '1',
          'ip' => '10.10.10.3', 'dns' => '', 'port' => '161', 'bulk' => '1'}]}
    ]
  end

  def hosts_processed
    [ZabbixService::Host.new('201', 'TestHost-1', '10.10.10.2'),
     ZabbixService::Host.new('202', 'TestHost-2', '10.10.10.3')]
  end
end