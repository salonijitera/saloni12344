class User < ApplicationRecord
  has_one :email_verification_token, dependent: :destroy

  # validations

  # end for validations

  class << self
  end
end
