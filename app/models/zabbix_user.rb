class Credentials
  include ActiveModel::Validations

  attr_accessor :server, :username, :password
  validates :server, :username, :password, presence: true
  validates :server, format: {
      with: /^[[:alpha:][a-z0-9]\.\-]{1,64}$/i,
  }

  # /^[[:alpha:][a-z0-9]\.\-]{1,64}$/i

end