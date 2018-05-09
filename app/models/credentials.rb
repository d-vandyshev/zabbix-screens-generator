class Credentials
  include ActiveModel::Validations

  REGEXP_CRED = /^[[:alpha:][a-z0-9]\.\-]{1,32}$/i

  attr_accessor :server, :username, :password
  validates :password, length: {
      maximum: 128,
      too_long: I18n.t('login.username_error')
  }
  validates :server, :username, :password, presence: true
  validates :username, format: {
      with: REGEXP_CRED,
      message: I18n.t('login.server_error')
  }
  validates :username, format: {
      with: REGEXP_CRED,
      message: I18n.t('login.username_error')
  }

end