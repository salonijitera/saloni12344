module UserService
  class Update < BaseService
    def initialize(user_id, email, password, password_confirmation)
      @user_id = user_id
      @email = email
      @password = password
      @password_confirmation = password_confirmation
    end

    def call
      return { error: I18n.t('activerecord.errors.messages.blank') } if [@user_id, @email, @password, @password_confirmation].any?(&:blank?)
      return { error: I18n.t('activerecord.errors.models.user.attributes.password_confirmation.confirmation') } if @password != @password_confirmation
      return { error: I18n.t('activerecord.errors.messages.invalid') } unless email_valid?(@email)

      user = User.find_by(id: @user_id)
      return { error: I18n.t('activerecord.errors.messages.not_found') } unless user
      return { error: I18n.t('activerecord.errors.messages.taken') } if email_taken?(user)

      encrypted_password = Devise::Encryptor.digest(User, @password)
      user.update(email: @email, password_hash: encrypted_password)

      { success: I18n.t('devise.registrations.updated') }
    end

    private

    def email_valid?(email)
      email =~ URI::MailTo::EMAIL_REGEXP
    end

    def email_taken?(user)
      User.where.not(id: user.id).exists?(email: @email)
    end
  end
end
