
class User < ApplicationRecord
  has_one :email_verification_token, dependent: :destroy
  has_many :email_verification_tokens

  # validations
  validates_presence_of :email, :password
  # end for validations

  class << self
  end
end
