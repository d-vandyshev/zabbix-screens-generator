class Credentials
  include ActiveModel::Model
  attr_accessor :server, :username, :password

  REGEXP_CRED = /\A[[:alpha:][a-z0-9]\.-]{1,32}\z/i.freeze
  validates :server, :username, :password, presence: true
  validates :server, format: REGEXP_CRED
  validates :username, format: REGEXP_CRED
  validates :password, length: { maximum: 128 }
end
