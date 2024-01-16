module UserService
  class VerifyEmail < BaseService
    def initialize(token)
      @token = token
    end

    def call
      token_record = EmailVerificationToken.find_by(token: @token, is_used: false)
      if token_record && token_record.expires_at > Time.current
        token_record.update!(is_used: true)
        user = token_record.user
        user.update!(is_email_verified: true)
        { message: 'Email successfully verified.' }
      else
        raise StandardError, 'Invalid or expired token.'
      end
    rescue StandardError => e
      { error: e.message }
    end

    private

    attr_reader :token
  end
end
