class ZabbixUser
  include ActiveModel::Model

  attr_accessor :host, :name, :password
  validates :host, :username, :password, presence: true

end